# Central de Notificaciones — Buk

Mini central de notificaciones que resuelve los problemas de spam, inconsistencia de canales y falta de auditoría. Implementa la API especificada en el caso técnico.

## Stack

- **Ruby on Rails 8.1** (modo API)
- **PostgreSQL** — base de datos y cola de jobs (Solid Queue)
- **Sendgrid** — canal de email
- **Solid Queue** — procesamiento de jobs en background (sin Redis)

---

## Estructura de archivos clave

```
app/
├── notifications/                    # Capa de definición (Parte 1.1)
│   ├── abstract_notificacion.rb      # Clase base — anti-spam, encolado, orquestación
│   ├── birthday_notification.rb      # Ejemplo: notificación de cumpleaños
│   ├── survey_notification.rb        # Ejemplo: encuesta (ventana de 7 días)
│   └── channels/                     # Patrón Strategy — canales intercambiables
│       └── email_channel.rb          # Canal email via Sendgrid
│
├── jobs/
│   └── send_notification_job.rb      # Job async — entrega + auditoría
│
└── models/
    └── notification_log.rb           # Registro de auditoría en PostgreSQL
```

---

## Configuración local

### 1. Variables de entorno

```bash
cp .env.example .env
```

Editar `.env` con tus credenciales:

```
SENDGRID_API_KEY=SG.xxxxx
NOTIFICATION_SENDER_EMAIL=notificaciones@tudominio.cl
DATABASE_URL=postgresql://usuario:password@host:5432/nombre_bd
```

`DATABASE_URL` acepta cualquier instancia PostgreSQL — local, Docker o cloud (Supabase, Railway, etc.). Si no se define, Rails usa la configuración de `config/database.yml`.

### 2. Base de datos

```bash
rails db:migrate
```

### 3. Levantar el servidor

```bash
rails server
```

### 4. Levantar el worker de jobs (en otra terminal)

```bash
bin/jobs
```

---

## Uso de la API

### Parte 1.1 — Definir una notificación nueva

Crear un archivo en `app/notifications/`. Solo dos métodos requeridos:

```ruby
# app/notifications/reminder_notification.rb
class ReminderNotification < AbstractNotificacion
  def self.title = "Recordatorio importante"
  def self.body  = "Tienes una tarea pendiente en Buk."
end
```

### Parte 1.2 — Enviar la notificación

Desde cualquier punto del monolito:

```ruby
BirthdayNotification.send('juan_perez@empresa.cl')
SurveyNotification.send('maria@empresa.cl')
ReminderNotification.send('pedro@empresa.cl')
```

### API REST (demo)

```bash
# Enviar notificación de cumpleaños
curl -X POST http://localhost:3000/notifications/birthday \
     -H "Content-Type: application/json" \
     -d '{"email": "juan@empresa.cl"}'

# Enviar encuesta
curl -X POST http://localhost:3000/notifications/survey \
     -H "Content-Type: application/json" \
     -d '{"email": "juan@empresa.cl"}'

# Ver historial de auditoría
curl http://localhost:3000/notifications/history
curl http://localhost:3000/notifications/history?email=juan@empresa.cl
curl http://localhost:3000/notifications/history?status=failed
```

---

## Agregar un canal nuevo (Parte 2 — extensión)

Crear una clase en `app/notifications/channels/`:

```ruby
# app/notifications/channels/slack_channel.rb
module Channels
  class SlackChannel
    def self.deliver(title:, body:, recipient:)
      # recipient = webhook URL o user ID de Slack
      Slack::Notifier.new(recipient).ping("*#{title}*\n#{body}")
    end
  end
end
```

Activarlo en `AbstractNotificacion` (una línea):

```ruby
def self.channels
  [Channels::EmailChannel, Channels::SlackChannel]
end
```

**Ninguna notificación existente cambia.**

---

## Anti-spam

La clase base previene automáticamente envíos duplicados.
La ventana por defecto es de **24 horas**, configurable por notificación:

```ruby
class UrgentNotification < AbstractNotificacion
  def self.spam_window = nil    # sin límite (siempre envía)
end

class SurveyNotification < AbstractNotificacion
  def self.spam_window = 7.days  # máximo una encuesta por semana
end
```

---

## Decisiones técnicas

| Decisión | Alternativa descartada | Razón |
|----------|----------------------|-------|
| Solid Queue (PostgreSQL) | Sidekiq + Redis | No introduce Redis como dependencia nueva; el stack ya tiene PostgreSQL |
| Métodos de clase (`self.`) | Métodos de instancia | Las notificaciones son tipos, no objetos con estado; `XNotif.send(email)` es la API pedida |
| Patrón Strategy en canales | Switch/case en el job | Agregar canal = nueva clase, sin tocar código existente |
| Anti-spam en la clase base | Delegado a cada equipo | Centralizado = ningún equipo puede olvidarlo |
| `send` como nombre de método | `dispatch`, `deliver` | Es la API especificada en el enunciado |
