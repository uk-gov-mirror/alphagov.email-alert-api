class MatchedContentChangeGenerationService
  def initialize(content_change:)
    @content_change = content_change
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    MatchedContentChange.import!(columns, records)
  end

  private_class_method :new

private

  attr_reader :content_change

  def columns
    %i(content_change_id subscriber_list_id, or_joined_subscriber_list_id)
  end

  # When we retrieve the matched content changes, we need to know whether something
  # is a `SubscriberList` or an `OrJoinedSubscriberList` so we put them in separate columns
  # This could probably benefit from a refactor
  def records
    content_change_id = content_change.id
    records = []
    or_joined_subscriber_list_ids = []
    subscriber_lists.each do |subscriber_list|
      if subscriber_list.or_joined_subscriber_lists.any?
        subscriber_list.or_joined_subscriber_lists.pluck(:or_joined_subscriber_list).each do |or_joined_subscriber_list_id|
          if not or_joined_subscriber_list_ids.include?(or_joined_subscriber_list_id)
            records << [content_change_id, nil, or_joined_subscriber_list_id]
            or_joined_subscriber_list_ids << or_joined_subscriber_list_id
          end
        end
      else
        records << [content_change_id, subscriber_list.id, nil]
      end
    end
    records
  end

  def subscriber_lists
    SubscriberListQuery.new(
      tags: content_change.tags,
      links: content_change.links,
      document_type: content_change.document_type,
      email_document_supertype: content_change.email_document_supertype,
      government_document_supertype: content_change.government_document_supertype,
      content_purpose_supergroup: content_change.content_purpose_supergroup,
    ).lists
  end
end
