class NotifyProvider
  def initialize(config: EmailAlertAPI.config.notify, notify_client: EmailAlertAPI.config.notify_client)
    @client = notify_client
    @template_id = config.fetch(:template_id)
  end

  def self.call(*args)
    new.call(*args)
  end

  def call(address:, subject:, body:, reference:)
    client.send_email(
      email_address: address,
      template_id: template_id,
      reference: reference,
      personalisation: {
        subject: subject,
        body: body,
      },
    )

    Metrics.sent_to_notify_successfully
    :sending
  # this rescue should catch all the errors we anticipate Notify raising
  # that don't require us to take action
  rescue Notifications::Client::RequestError, Net::Timeout => e
    Metrics.failed_to_send_to_notify
    # log error
    determine_error_status(e)
  end

private

  attr_reader :client, :template_id

  def determine_error_status(error)
    return :retryable_failure unless error.is_a?(Notifications::Client::ClientError)

    # TODO set up a permanent failure scenario for invalid email address

    :retryable_failure
  end
end
