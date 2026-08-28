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
        reply_to: { email: SENDER_EMAIL, name: SENDER_NAME },
        subject: title,
        content: [
          { type: "text/plain", value: body },
          { type: "text/html",  value: build_html(title:, body:) }
        ]
      }
    end

    def self.build_html(title:, body:)
      <<~HTML
        <!DOCTYPE html>
        <html lang="es">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>#{title}</title>
          </head>
          <body style="margin:0;padding:0;background-color:#f4f4f4;font-family:Arial,sans-serif;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f4f4f4;padding:40px 0;">
              <tr>
                <td align="center">
                  <table width="560" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:6px;overflow:hidden;">
                    <tr>
                      <td style="background-color:#1a1a2e;padding:24px 32px;">
                        <p style="margin:0;color:#ffffff;font-size:18px;font-weight:bold;">Buk</p>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding:36px 32px;">
                        <h1 style="margin:0 0 16px;font-size:22px;color:#1a1a2e;">#{title}</h1>
                        <p style="margin:0 0 24px;font-size:15px;color:#444444;line-height:1.7;">#{body}</p>
                        <hr style="border:none;border-top:1px solid #eeeeee;margin:24px 0;">
                        <p style="margin:0;font-size:12px;color:#999999;">Este mensaje fue enviado automáticamente por la plataforma Buk. Por favor no respondas este correo.</p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </body>
        </html>
      HTML
    end
  end
end
