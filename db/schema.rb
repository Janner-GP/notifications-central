# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_26_120000) do
  create_schema "extensions"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "public.notification_logs", force: :cascade do |t|
    t.string "channel", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "notification_type", null: false
    t.string "recipient", null: false
    t.string "status", default: "sent", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_type", "recipient", "created_at"], name: "idx_notification_logs_antispam"
    t.index ["recipient"], name: "index_notification_logs_on_recipient"
    t.index ["status"], name: "index_notification_logs_on_status"
  end

end
