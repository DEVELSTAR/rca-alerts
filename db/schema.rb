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

ActiveRecord::Schema[8.0].define(version: 2025_09_24_072657) do
  create_table "endpoint_configurations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "organisation_id"
    t.bigint "endpoint_monitoring_group_id"
    t.bigint "associated_resoures_id"
    t.string "associated_resoures_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["associated_resoures_type", "associated_resoures_id"], name: "index_endpoint_configs_on_associated_resource"
  end

  create_table "endpoint_monitoring_endpoints", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "endpoint_monitoring_group_id", null: false
    t.string "endpoint_name", null: false
    t.string "host", null: false
    t.string "monitoring_mode", null: false
    t.integer "port"
    t.integer "latency_critical"
    t.integer "packet_loss_critical"
    t.integer "latency_warning"
    t.integer "packet_loss_warning"
    t.integer "response_time"
    t.json "acceptable_response_codes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint_monitoring_group_id"], name: "idx_on_endpoint_monitoring_group_id_1f2ab4005c"
    t.index ["endpoint_name"], name: "index_endpoint_monitoring_endpoints_on_endpoint_name"
    t.index ["host"], name: "index_endpoint_monitoring_endpoints_on_host"
    t.index ["monitoring_mode"], name: "index_endpoint_monitoring_endpoints_on_monitoring_mode"
  end

  create_table "endpoint_monitoring_groups", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "group_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_type"], name: "index_endpoint_monitoring_groups_on_group_type"
    t.index ["name"], name: "index_endpoint_monitoring_groups_on_name"
  end

  create_table "rca_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "ts"
    t.string "location"
    t.string "isp"
    t.string "endpoint"
    t.string "metric_type"
    t.float "value"
    t.float "baseline"
    t.string "severity"
    t.text "message"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alerted"
  end

  add_foreign_key "endpoint_monitoring_endpoints", "endpoint_monitoring_groups"
end
