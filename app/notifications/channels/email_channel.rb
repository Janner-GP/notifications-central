module Channels
  class EmailChannel
    SENDER_EMAIL = ENV.fetch("NOTIFICATION_SENDER_EMAIL", "notificaciones@buk.cl")
    SENDER_NAME  = "Buk Notificaciones"

    def self.deliver(title:, body:, recipient:)
      response = sendgrid_client.client.mail._("send").post(request_body: build_payload(title:, body:, recipient:))

      unless response.status_code.to_i == 202
        raise DeliveryError, "Sendgrid respondió #{response.status_code}: #{response.body}"
      end

      Rails.logger.info("[EmailChannel] Enviado a #{recipient} | Asunto: #{title}")
    end

    class DeliveryError < StandardError; end

    private

    def self.sendgrid_client
      SendGrid::API.new(api_key: ENV.fetch("SENDGRID_API_KEY"))
    end

    # Construye el payload que espera la API de Sendgrid
    def self.build_payload(title:, body:, recipient:)
      {
        personalizations: [{ to: [{ email: recipient }] }],
        from:    { email: SENDER_EMAIL, name: SENDER_NAME },
        subject: title,
        content: [{ type: "text/plain", value: body }]
      }
    end
  end
end
