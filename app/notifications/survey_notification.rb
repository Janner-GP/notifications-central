# Notificación de encuesta.
#
# Ejemplo que sobreescribe spam_window para permitir envíos más frecuentes
# (una encuesta por semana en vez de la ventana por defecto de 24h).
#
# Uso:
#   SurveyNotification.send('maria_gonzalez@empresa.cl')
#
class SurveyNotification < AbstractNotificacion
  def self.title = "Te invitamos a responder una breve encuesta"
  def self.body  = "Tu opinión es muy importante para nosotros. La encuesta toma menos de 2 minutos."

  # Las encuestas pueden enviarse una vez por semana (sobreescribe el default de 24h)
  def self.spam_window = 7.days
end
