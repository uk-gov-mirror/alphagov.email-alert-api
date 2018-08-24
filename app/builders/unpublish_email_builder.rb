class UnpublishEmailBuilder
  def self.call(*args)
    new.call(*args)
  end

  def call(emails, redirect)
    ids = Email.import!(email_records(emails, redirect)).ids
    Email.where(id: ids)
  end

private

  def email_records(emails, redirect)
    emails.map do |email|
      {
        address: email.fetch(:address),
        subject: email.fetch(:subject),
        body: body(email.fetch(:subject), email.fetch(:address), redirect),
        subscriber_id: email.fetch(:subscriber_id)
      }
    end
  end

  def body(title, address, redirect)
    <<~BODY
      Your subscription to email updates about '#{title}' has ended because this topic no longer exists on GOV.UK.

      You might want to subscribe to updates about '#{redirect.title}' instead: [#{redirect.url}](#{add_utm(redirect.url, title)})

      #{presented_manage_subscriptions_links(address)}
    BODY
  end

  def add_utm(url, title)
    utm_source = title
    utm_medium = "email"
    utm_campaign = "govuk-notifications"
    utm_content = title

    uri = URI.parse(url)
    uri.query = [uri.query,
                 "utm_source=#{utm_source}",
                 "utm_medium=#{utm_medium}",
                 "utm_campaign=#{utm_campaign}",
                 "utm_content=#{utm_content}"].compact.join('&')
    uri.to_s
  end

  def presented_manage_subscriptions_links(address)
    ManageSubscriptionsLinkPresenter.call(address: address)
  end
end
