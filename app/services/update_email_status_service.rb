class UpdateEmailStatusService < ApplicationService
  def initialize(delivery_attempt)
    @delivery_attempt = delivery_attempt
  end

  def call
    handle_retryable_failure if delivery_attempt.retryable_failure?
    handle_permanent_failure if delivery_attempt.permanent_failure?
    handle_delivered if delivery_attempt.delivered?
  end

private

  attr_reader :delivery_attempt
  delegate :email, :finished_sending_at, to: :delivery_attempt

  def handle_retryable_failure
    return unless retries_exhausted?

    email.mark_as_failed(:retries_exhausted_failure, finished_sending_at)
  end

  def retries_exhausted?
    first_completed = DeliveryAttempt.where(email: email).minimum(:completed_at)
    first_completed && first_completed < Email::RETRY_TIMEOUT.ago
  end

  def handle_permanent_failure
    email.mark_as_failed(:permanent_failure, finished_sending_at)
  end

  def handle_delivered
    email.mark_as_sent(:sent, finished_sending_at)
  end
end
