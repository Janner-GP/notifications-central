class CreateNotificationLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_logs do |t|
      # Tipo de notificación: "BirthdayNotification", "SurveyNotification", etc.
      t.string :notification_type, null: false

      # Destinatario: email del usuario
      t.string :recipient, null: false

      # Canal usado: "Channels::EmailChannel" (en el futuro: WhatsApp, Slack)
      t.string :channel, null: false

      # Estado del envío: "sent" o "failed"
      t.string :status, null: false, default: "sent"

      # Mensaje de error si el envío falló (nil si fue exitoso)
      t.text :error_message

      t.timestamps
    end

    # Índice para la query de anti-spam:
    #   WHERE notification_type = ? AND recipient = ? AND created_at > ?
    # Este índice hace esa consulta O(log n) con millones de registros.
    add_index :notification_logs,
              %i[notification_type recipient created_at],
              name: "idx_notification_logs_antispam"

    # Índice para filtros del historial de auditoría
    add_index :notification_logs, :status
    add_index :notification_logs, :recipient
  end
end
