Rails.application.routes.draw do
  # ── Central de Notificaciones ────────────────────────────────────────
  #
  # Parte 1.2: API para gatillar el envío de una notificación
  post "/notifications/birthday", to: "notifications#birthday"  # { email: "..." }
  post "/notifications/survey",   to: "notifications#survey"    # { email: "..." }

  # Parte 2: historial de auditoría
  # GET /notifications/history?email=...&type=...&status=...&limit=50
  get "/notifications/history", to: "notifications#history"

  get "up" => "rails/health#show", as: :rails_health_check
end
