class SubscriptionBuilderService
  def initialize(subscriber, subscriber_list, frequency, signon_user_id)
    @subscriber = subscriber
    @subscriber_list = subscriber_list
    @frequency = frequency
    @signon_user_id = signon_user_id
  end

  def call
    if subscriber_list.kind_of?(SubscriberList)
      subscription = nil
      Subscription.transaction do
        existing_subscription.end(reason: :frequency_changed) if existing_subscription
        subscriber.activate! if subscriber.deactivated?
        subscription = create_subscription
      end
      [subscription, status]
    end

    def status
      @existing_subscription ? :ok : :created
    end
  end

private
  attr_accessor :subscriber, :subscriber_list, :frequency, :signon_user_id

  def existing_subscription
    @existing_subscription ||= begin
      parameters = { subscriber: subscriber }
      if subscriber_list.is_a(SubscriberList)
        parameters.merge(subscriber_list: subscriber_list)
      else
        parameters.merge(or_joined_subscriber_list: subscriber_list)
      end
      Subscription.active.lock.find_by(parameters)
    end
  end

  def create_subscription
    parameters = {
        subscriber: subscriber,
        frequency: frequency,
        signon_user_uid: current_user.uid,
        source: !existing_subscription ? :frequency_changed : :user_signed_up
    }
    if subscriber_list.is_a(SubscriberList)
      parameters.merge(subscriber_list: subscriber_list)
    else
      parameters.merge(or_joined_subscriber_list: subscriber_list)
    end
    Subscription.create!(parameters)
  end
end
