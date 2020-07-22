class Email < ApplicationRecord
  # Any validations added this to this model won't be applied on record
  # creation as this table is populated by the #insert_all bulk method

  COURTESY_EMAIL = "govuk-email-courtesy-copies@digital.cabinet-office.gov.uk".freeze

  # Time period that we're happy to retry sending an email before giving up
  RETRY_TIMEOUT = 24.hours

  has_many :delivery_attempts

  scope :archivable,
        lambda {
          where(archived_at: nil).where.not(status: :pending)
        }

  scope :deleteable,
        lambda {
          where.not(status: :pending).where("archived_at < ?", 7.days.ago)
        }

  enum status: { pending: 0, sent: 1, failed: 2 }
  enum failure_reason: { permanent_failure: 0, retries_exhausted_failure: 1, technical_failure: 2 }

  def self.timed_bulk_insert(records, batch_size)
    return insert_all!(records) unless records.size == batch_size

    Metrics.email_bulk_insert(batch_size) { insert_all!(records) }
  end

  def mark_as_sent(finished_sending_at)
    email.update!(
      status: :sent,
      finished_sending_at: finished_sending_at,
    )
  end

  def mark_as_failed(failure_reason, finished_sending_at)
    email.update!(
      status: :failed,
      failure_reason: failure_reason,
      finished_sending_at: finished_sending_at,
    )
  end
end
