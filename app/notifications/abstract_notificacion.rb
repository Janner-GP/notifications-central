class AbstractNotificacion
  # Subclases deben implementar estos dos métodos
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

  def self.send(recipient)
    return if already_sent?(recipient)

    channels.each do |channel|
      SendNotificationJob.perform_later(
        notification_type: name,
        recipient:         recipient,
        title:             title,
        body:              body,
        channel:           channel.name
      )
    end
  end

  def self.already_sent?(recipient)
    return false if spam_window.nil?

    NotificationLog
      .where(notification_type: name, recipient: recipient, status: "sent")
      .where("created_at > ?", spam_window.ago)
      .exists?
  end

  private_class_method :already_sent?
end
