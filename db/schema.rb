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

ActiveRecord::Schema[8.1].define(version: 2026_08_03_152125) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "login_events", force: :cascade do |t|
    t.string "client", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "occurred_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "occurred_at"], name: "index_login_events_on_user_id_and_occurred_at"
    t.index ["user_id"], name: "index_login_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "course", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "email_verification_code_digest"
    t.datetime "email_verification_expires_at"
    t.datetime "email_verification_sent_at"
    t.datetime "email_verified_at"
    t.string "matricula", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "password_reset_code_digest"
    t.datetime "password_reset_expires_at"
    t.datetime "password_reset_sent_at"
    t.datetime "terms_accepted_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["matricula"], name: "index_users_on_matricula", unique: true
  end

  add_foreign_key "login_events", "users"
end
