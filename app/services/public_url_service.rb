module PublicUrlService
  class << self
    def url_for(base_path:)
      URI.join(website_root, base_path).to_s
    end

    # This url is for the page mid-way through the signup journey where the user
    # enters their email address. At present, multiple frontends start the
    # journey, e.g. collections, but eventually all these will be consolidated
    # into email-alert-frontend and this URL will no longer be needed.
    def subscription_url(slug:, existing_subscriber_list_slugs_to_be_or_joined: [])
      params = { topic_id: subscriber_list_slug(slug, or_joined_slugs) }.to_query
      "#{website_root}/email/subscriptions/new?#{params}"
    end

    def authenticate_url(address:)
      "#{website_root}/email/authenticate?#{param('address', address)}"
    end

    def absolute_url(path:)
      File.join(website_root, path)
    end

  private

    def website_root
      Plek.new.website_root
    end

    def or_joined_subscriber_list_slug(slug, or_joined_slugs)
      all_slugs = Array(slug) + or_joined_slugs
      return slug if all_slugs.one?

      subscriber_lists = SubscriberList.where(slug: all_slugs)
      OrJoinedSubscriberList.slug(subscriber_lists)
    end
  end
end
