class NotificationLog < ApplicationRecord
  STATUSES = %w[sent failed].freeze

  validates :notification_type, :recipient, :channel, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  # Scopes para filtrar el historial desde el controller
  scope :recent,        -> { order(created_at: :desc) }
  scope :for_recipient, ->(email) { where(recipient: email) }
  scope :by_type,       ->(type)  { where(notification_type: type) }
  scope :sent,          -> { where(status: "sent") }
  scope :failed,        -> { where(status: "failed") }
end
