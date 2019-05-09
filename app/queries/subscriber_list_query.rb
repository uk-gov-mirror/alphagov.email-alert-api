class SubscriberListQuery
  def initialize(tags:, links:, document_type:, email_document_supertype:, government_document_supertype:, content_purpose_supergroup:)
    @tags = tags.symbolize_keys
    @links = links.symbolize_keys
    @document_type = document_type
    @email_document_supertype = email_document_supertype
    @government_document_supertype = government_document_supertype
    @content_purpose_supergroup = content_purpose_supergroup
  end

  def lists
    @lists ||= (
      lists_matched_on_links +
      lists_matched_on_tags +
      lists_matched_on_document_type_only
    ).uniq(&:id)
  end

private

  def lists_matched_on_tags
    MatchedForNotification.new(query_field: :tags, scope: base_scope).call(@tags)
  end

  def lists_matched_on_links
    MatchedForNotification.new(query_field: :links, scope: base_scope).call(@links)
  end

  def lists_matched_on_document_type_only
    FindWithoutLinksAndTags.new(scope: base_scope).call
  end

  def base_scope
    # In the calling class (MatchedContentChangeGenerationService) it iterates over the result
    # of lists, which will be subscriber lists and checkes how many of or_joined_subscriber_lists there are for each subscriber list
    #
    # This will result in an n+1 query which we want to avoid, we will want to use something like the following
    # (but, you know, that actually includes the or_joined_subscriber_lists) to prevent this
    #
    #
    #  SubscriberList
    #       .joins(:or_joined_subscriber_list_subscriber_lists)
    #       .includes(:or_joined_subscriber_lists, :or_joined_subscriber_list_subscriber_lists)
    #       .where(document_type: ['', @document_type])
    #       .where(email_document_supertype: ['', @email_document_supertype])
    #       .where(government_document_supertype: ['', @government_document_supertype])
    #       .where(content_purpose_supergroup: [nil, @content_purpose_supergroup])
    #
    #
    SubscriberList
      .where(document_type: ['', @document_type])
      .where(email_document_supertype: ['', @email_document_supertype])
      .where(government_document_supertype: ['', @government_document_supertype])
      .where(content_purpose_supergroup: [nil, @content_purpose_supergroup])
  end
end
