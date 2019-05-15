class SubscriberListBuilderService
  def initialize(subcriber_list_params, existing_subscriber_list_slugs_to_be_or_joined)
    @subcriber_list_params = subcriber_list_params
    @existing_subscriber_list_slugs_to_be_or_joined = existing_subscriber_list_slugs_to_be_or_joined
  end

  def call
    # TODO: Probably too many returns here, clean up
    subscriber_list = SubscriberList.new(subscriber_list_params)
    return [ false, subscriber_list.errors.full_messages.to_sentence ] unless subscriber_list.save

    if existing_subscriber_list_slugs_to_be_or_joined.empty?
      return [true, subscriber_list.to_json(existing_subscriber_list_slugs_to_be_or_joined)]
    else
      # This could probably be tightened up
      or_joined_subscriber_list = OrJoinedSubscriberList.find_by(slug: OrJoinedSubscriberList.slug(subscriber_lists))
      return [ true, or_joined_subscriber_list.to_json ] if or_joined_subscriber_list

      or_joined_subscriber_list = OrJoinedSubscriberList.create(slug: OrJoinedSubscriberList.slug(subscriber_lists))
      or_joined_subscriber_list.subscriber_lists = subscriber_lists
      or_joined_subscriber_list.save

      success = or_joined_subscriber_list.errors.empty?
      message = success ?  or_joined_subscriber_list.to_json : or_joined_subscriber_list.errors.full_messages.to_sentence
      return [ success, message]
    end
  end

private

  attr_reader :subscriber_list_params, :existing_subscriber_list_slugs_to_be_or_joined

  def subscriber_lists
    @subscriber_lists ||= SubscriberList.where(slug: existing_subscriber_list_slugs_to_be_or_joined)
  end
end
