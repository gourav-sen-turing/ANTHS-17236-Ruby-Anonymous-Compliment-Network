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

ActiveRecord::Schema[7.2].define(version: 2025_06_06_101838) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "icon"
    t.string "color", limit: 7
    t.text "template_text"
    t.boolean "system", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "compliments_count", default: 0
    t.index ["name"], name: "index_categories_on_name_and_community_id", unique: true
  end

  create_table "categories_compliments", id: false, force: :cascade do |t|
    t.integer "compliment_id", null: false
    t.integer "category_id", null: false
    t.index ["category_id", "compliment_id"], name: "index_categories_compliments_on_category_id_and_compliment_id"
    t.index ["compliment_id", "category_id"], name: "index_categories_compliments_on_compliment_id_and_category_id", unique: true
  end

  create_table "communities", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "community_type", default: 0
    t.string "domain"
    t.integer "privacy_level", default: 0
    t.integer "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "compliments_count", default: 0
    t.index ["community_type"], name: "index_communities_on_community_type"
    t.index ["creator_id"], name: "index_communities_on_creator_id"
    t.index ["domain"], name: "index_communities_on_domain"
    t.index ["name"], name: "index_communities_on_name"
    t.index ["slug"], name: "index_communities_on_slug", unique: true
  end

  create_table "community_categories", force: :cascade do |t|
    t.integer "community_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_community_categories_on_category_id"
    t.index ["community_id", "category_id"], name: "index_community_categories_on_community_id_and_category_id", unique: true
    t.index ["community_id"], name: "index_community_categories_on_community_id"
  end

  create_table "compliments", force: :cascade do |t|
    t.text "content", null: false
    t.integer "recipient_id", null: false
    t.integer "sender_id"
    t.boolean "anonymous", default: false
    t.string "status", default: "pending"
    t.datetime "read_at"
    t.integer "community_id"
    t.string "category"
    t.integer "kudos_count", default: 0
    t.integer "reports_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "anonymous_token"
    t.string "sender_ip_hash"
    t.integer "category_id"
    t.index ["anonymous"], name: "index_compliments_on_anonymous"
    t.index ["anonymous_token"], name: "index_compliments_on_anonymous_token", unique: true
    t.index ["category"], name: "index_compliments_on_category"
    t.index ["category_id"], name: "index_compliments_on_category_id"
    t.index ["community_id"], name: "index_compliments_on_community_id"
    t.index ["read_at"], name: "index_compliments_on_read_at"
    t.index ["recipient_id"], name: "index_compliments_on_recipient_id"
    t.index ["sender_id"], name: "index_compliments_on_sender_id"
    t.index ["status"], name: "index_compliments_on_status"
  end

  create_table "kudos", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "compliment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compliment_id"], name: "index_kudos_on_compliment_id"
    t.index ["user_id"], name: "index_kudos_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "community_id", null: false
    t.integer "role", default: 0
    t.integer "status", default: 0
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id", "role"], name: "index_memberships_on_community_id_and_role"
    t.index ["community_id", "status"], name: "index_memberships_on_community_id_and_status"
    t.index ["community_id"], name: "index_memberships_on_community_id"
    t.index ["role"], name: "index_memberships_on_role"
    t.index ["status"], name: "index_memberships_on_status"
    t.index ["user_id", "community_id"], name: "index_memberships_on_user_id_and_community_id", unique: true
    t.index ["user_id", "status"], name: "index_memberships_on_user_id_and_status"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "mood_entries", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.text "notes"
    t.datetime "recorded_at", null: false
    t.integer "compliment_id"
    t.string "context"
    t.string "factors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compliment_id"], name: "index_mood_entries_on_compliment_id"
    t.index ["context"], name: "index_mood_entries_on_context"
    t.index ["recorded_at"], name: "index_mood_entries_on_recorded_at"
    t.index ["user_id", "recorded_at"], name: "index_mood_entries_on_user_id_and_recorded_at"
    t.index ["user_id"], name: "index_mood_entries_on_user_id"
    t.index ["value"], name: "index_mood_entries_on_value"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "reporter_id", null: false
    t.integer "compliment_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compliment_id"], name: "index_reports_on_compliment_id"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
  end

  create_table "test_tables", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username"
    t.string "anonymous_identifier"
    t.string "name"
    t.string "email_domain"
    t.text "bio"
    t.boolean "profile_visible", default: true
    t.string "role", default: "user"
    t.integer "mood"
    t.datetime "mood_updated_at"
    t.integer "compliments_sent_count", default: 0
    t.integer "compliments_received_count", default: 0
    t.integer "kudos_received_count", default: 0
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_mood"
    t.integer "anonymity_level", default: 0, null: false
    t.index ["anonymity_level"], name: "index_users_on_anonymity_level"
    t.index ["anonymous_identifier"], name: "index_users_on_anonymous_identifier", unique: true
    t.index ["current_mood"], name: "index_users_on_current_mood"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "communities", "users", column: "creator_id"
  add_foreign_key "community_categories", "categories"
  add_foreign_key "community_categories", "communities"
  add_foreign_key "compliments", "categories"
  add_foreign_key "compliments", "communities"
  add_foreign_key "compliments", "users", column: "recipient_id"
  add_foreign_key "compliments", "users", column: "sender_id"
  add_foreign_key "kudos", "compliments"
  add_foreign_key "kudos", "users"
  add_foreign_key "memberships", "communities"
  add_foreign_key "memberships", "users"
  add_foreign_key "mood_entries", "compliments"
  add_foreign_key "mood_entries", "users"
  add_foreign_key "reports", "compliments"
  add_foreign_key "reports", "reporters"
end
