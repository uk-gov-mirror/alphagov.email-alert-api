class SubscriptionContentWorker
  include Sidekiq::Worker

  def perform(content_change_id, batch_size = 1000)
    content_change = ContentChange.find(content_change_id)
    return if content_change.processed?

    queue_delivery_to_subscribers(content_change, batch_size: batch_size)
    queue_delivery_to_courtesy_subscribers(content_change)

    content_change.mark_processed!
  end

private

  def queue_delivery_to_subscribers(content_change, batch_size: 1000)
    content_change_id = content_change.id
    batch = []

    # Here we put all the subscriptions into batches and send them to #import_subscription_contents_batch
    # in those batches
    grouped_subscription_ids_by_subscriber(content_change).each do |subscription_ids|
      records = subscription_ids.map do |subscription_id|
        [content_change_id, subscription_id]
      end

      batch.concat(records)

      if batch.size >= batch_size
        import_subscription_contents_batch(batch)
        batch.clear
      end
    end

    import_subscription_contents_batch(batch) unless batch.empty?
  end

  # This takes a batch of arrays of content_ids matched to subscription_ids
  # and creates SubscriptionContent records for each one
  #
  # This is probably where we want to intervene to create SubscriptionContent records
  # that can have either a subscription_id OR a collection_id
  #
  # Then it runs ImmediateEmailGenerationWorke
  def import_subscription_contents_batch(batch)
    columns = %i(content_change_id subscription_id)

    begin
      SubscriptionContent.transaction do
        SubscriptionContent.import!(columns, batch)
      end
    rescue ActiveRecord::RecordNotUnique
      handle_failed_subscription_content_import(batch)
    end

    ImmediateEmailGenerationWorker.perform_async
  end

  def handle_failed_subscription_content_import(batch)
    SubscriptionContent.transaction do
      batch.each do |(content_change_id, subscription_id)|
        params = { content_change_id: content_change_id, subscription_id: subscription_id }
        SubscriptionContent.create!(params) unless SubscriptionContent.where(params).exists?
      end
    end
  end


  # Gets all the subscriptions where the matched content change is for our content change
  # and groups them by subscription.subscriber_id
  def grouped_subscription_ids_by_subscriber(content_change)
    ContentChangeImmediateSubscriptionQuery.call(content_change: content_change)
      .group(:subscriber_id)
      .pluck(Arel.sql("ARRAY_AGG(subscriptions.id)"))
  end

  def queue_delivery_to_courtesy_subscribers(content_change)
    addresses = [
      Email::COURTESY_EMAIL,
    ]

    Subscriber.where(address: addresses).find_each do |subscriber|
      email_id = ImmediateEmailBuilder.call([
        {
          address: subscriber.address,
          subscriptions: [],
          content_change: content_change,
          subscriber_id: subscriber.id,
        }
      ]).ids.first

      DeliveryRequestWorker.perform_async_in_queue(
        email_id, queue: :delivery_immediate,
      )
    end
  end
end
