class SendNotificationJob < ApplicationJob
  queue_as :notifications

  # Reintenta hasta 5 veces con espera creciente antes de marcar como fallido
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_type:, recipient:, title:, body:, channel:)
    channel_class = channel.constantize

    channel_class.deliver(title: title, body: body, recipient: recipient)

    log_result(notification_type:, recipient:, channel:, status: "sent")

  rescue StandardError => e
    log_result(notification_type:, recipient:, channel:, status: "failed", error_message: e.message)
    raise
  end

  private

  def log_result(notification_type:, recipient:, channel:, status:, error_message: nil)
    NotificationLog.create!(
      notification_type: notification_type,
      recipient:         recipient,
      channel:           channel,
      status:            status,
      error_message:     error_message
    )
  end
end
