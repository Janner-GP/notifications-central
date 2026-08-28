# Demo de la API pública.
#
# Muestra cómo un equipo del monolito llama .send() y cómo
# consultar el historial de auditoría (Parte 2).
#
class NotificationsController < ApplicationController
  # POST /notifications/birthday
  # Body: { "email": "juan@empresa.cl" }
  def birthday
    validate_email! do
      BirthdayNotification.send(email: params[:email])
      render json: {
        status:    "encolado",
        type:      "BirthdayNotification",
        recipient: params[:email]
      }, status: :accepted
    end
  end

  # POST /notifications/survey
  # Body: { "email": "juan@empresa.cl" }
  def survey
    validate_email! do
      SurveyNotification.send(email: params[:email])
      render json: {
        status:    "encolado",
        type:      "SurveyNotification",
        recipient: params[:email]
      }, status: :accepted
    end
  end

  # GET /notifications/history
  # Query params opcionales: email=, type=, status=, limit=
  #
  # Parte 2: interfaz de auditoría — permite responder quién fue
  # notificado, cuándo y por qué canal.
  def history
    logs = NotificationLog.recent

    logs = logs.for_recipient(params[:email]) if params[:email].present?
    logs = logs.by_type(params[:type])        if params[:type].present?
    logs = logs.where(status: params[:status]) if params[:status].present?

    limit = (params[:limit] || 50).to_i.clamp(1, 200)

    render json: {
      total: logs.count,
      logs:  logs.limit(limit).as_json(only: %i[
        id notification_type recipient channel status error_message created_at
      ])
    }
  end

  private

  def validate_email!
    if params[:email].blank?
      render json: { error: "El parámetro 'email' es requerido" }, status: :bad_request
    else
      yield
    end
  end
end
