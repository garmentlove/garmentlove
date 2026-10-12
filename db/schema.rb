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

ActiveRecord::Schema[8.2].define(version: 2026_10_11_235603) do
  create_table "access_tokens", force: :cascade do |t|
    t.integer "identity_id", null: false
    t.string "token"
    t.string "permission"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_access_tokens_on_identity_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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

  create_table "addresses", force: :cascade do |t|
    t.integer "designation", default: 0, null: false
    t.string "street", null: false
    t.string "street2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "country", null: false
    t.string "zip", null: false
    t.string "addressable_type", null: false
    t.integer "addressable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "barcodes", force: :cascade do |t|
    t.text "value", null: false
    t.integer "symbology", default: 0, null: false
    t.string "scannable_type", null: false
    t.integer "scannable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scannable_type", "scannable_id"], name: "index_barcodes_on_scannable"
    t.index ["value"], name: "index_barcodes_on_value"
  end

  create_table "customers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "customer_type", default: "customer", null: false
  end

  create_table "email_addresses", force: :cascade do |t|
    t.string "address", null: false
    t.integer "designation", default: 0, null: false
    t.string "emailable_type", null: false
    t.integer "emailable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_email_addresses_on_address"
    t.index ["emailable_type", "emailable_id"], name: "index_email_addresses_on_emailable"
  end

  create_table "identities", force: :cascade do |t|
    t.string "userable_type", null: false
    t.integer "userable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["userable_type", "userable_id"], name: "index_identities_on_userable"
  end

  create_table "item_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "color"
    t.string "ancestry"
    t.boolean "required", default: false
    t.boolean "active", default: true
    t.string "select", default: "single", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_item_categories_on_ancestry"
    t.index ["name"], name: "index_item_categories_on_name"
  end

  create_table "item_descriptors", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "item_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_category_id"], name: "index_item_descriptors_on_item_category_id"
    t.index ["item_id"], name: "index_item_descriptors_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "customer_id"
    t.string "name"
    t.text "description"
    t.boolean "ownable", default: true, null: false
    t.integer "status", default: 0, null: false
    t.decimal "weight", precision: 8, scale: 2
    t.integer "bundle_quantity", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.integer "manual_price_cents"
    t.integer "unit_price_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_items_on_customer_id"
  end

  create_table "magic_links", force: :cascade do |t|
    t.string "code", limit: 255, null: false
    t.datetime "expires_at", null: false
    t.integer "identity_id", null: false
    t.integer "purpose"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_magic_links_on_identity_id"
  end

  create_table "order_line_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_order_line_items_on_item_id"
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
  end

  create_table "order_surcharge_lines", force: :cascade do |t|
    t.integer "price_surcharge_id", null: false
    t.integer "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_surcharge_lines_on_order_id"
    t.index ["price_surcharge_id"], name: "index_order_surcharge_lines_on_price_surcharge_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.string "order_type", default: "cleaning", null: false
    t.datetime "due_at", null: false
    t.datetime "fulfill_at"
    t.boolean "rush", default: false, null: false
    t.integer "pieces_count", default: 0, null: false
    t.text "notes"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
  end

  create_table "price_surcharges", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.text "description"
    t.integer "modifer", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "identity_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_sessions_on_identity_id"
  end

  create_table "telephones", force: :cascade do |t|
    t.integer "designation", default: 0, null: false
    t.string "number", null: false
    t.string "reachable_type", null: false
    t.integer "reachable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_telephones_on_number"
    t.index ["reachable_type", "reachable_id"], name: "index_telephones_on_reachable"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "access_tokens", "identities"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "item_descriptors", "item_categories"
  add_foreign_key "item_descriptors", "items"
  add_foreign_key "items", "customers"
  add_foreign_key "magic_links", "identities"
  add_foreign_key "order_line_items", "items"
  add_foreign_key "order_line_items", "orders"
  add_foreign_key "order_surcharge_lines", "orders"
  add_foreign_key "order_surcharge_lines", "price_surcharges"
  add_foreign_key "orders", "customers"
  add_foreign_key "sessions", "identities"
end
