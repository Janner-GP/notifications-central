class AbstractNotificacion
  def self.title
    raise NotImplementedError, "#{name} debe implementar self.title"
  end

  def self.body
    raise NotImplementedError, "#{name} debe implementar self.body"
  end

  # Canal por defecto: email. Sobreescribir en la subclase para agregar más.
  def self.channels
    [Channels::EmailChannel]
  end

  # Ventana anti-spam. nil = sin límite.
  def self.spam_window
    24.hours
  end

  # Clave que identifica al destinatario para el anti-spam.
  # Por defecto usa el email. Sobreescribir si el canal principal no usa email.
  def self.spam_key(context)
    context[:email] || context.values.first.to_s
  end

  # context es un hash libre con los datos del destinatario.
  # Cada canal toma solo las claves que necesita.
  # Ejemplos:
  #   BirthdayNotification.send(email: "juan@empresa.cl")
  #   AlertNotification.send(email: "juan@empresa.cl", phone: "+56912345678")
  def self.send(**context)
    return if already_sent?(context)

    channels.each do |channel|
      SendNotificationJob.perform_later(
        notification_type: name,
        context:           context.stringify_keys,
        title:             title,
        body:              body,
        channel:           channel.name
      )
    end
  end

  def self.already_sent?(context)
    return false if spam_window.nil?

    NotificationLog
      .where(notification_type: name, recipient: spam_key(context), status: "sent")
      .where("created_at > ?", spam_window.ago)
      .exists?
  end

  private_class_method :already_sent?
end
