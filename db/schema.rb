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

ActiveRecord::Schema[8.1].define(version: 2026_05_27_135834) do
  create_table "discentes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "curso"
    t.string "email"
    t.string "formacao"
    t.string "matricula"
    t.string "nome"
    t.string "ocupacao"
    t.integer "turma_id", null: false
    t.datetime "updated_at", null: false
    t.string "usuario"
    t.index ["turma_id"], name: "index_discentes_on_turma_id"
  end

  create_table "disciplinas", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "docentes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "departamento"
    t.string "email"
    t.string "formacao"
    t.string "nome"
    t.string "ocupacao"
    t.integer "turma_id", null: false
    t.datetime "updated_at", null: false
    t.string "usuario"
    t.index ["turma_id"], name: "index_docentes_on_turma_id"
  end

  create_table "turmas", force: :cascade do |t|
    t.string "classCode"
    t.datetime "created_at", null: false
    t.integer "disciplina_id", null: false
    t.string "semester"
    t.string "time"
    t.datetime "updated_at", null: false
    t.index ["disciplina_id"], name: "index_turmas_on_disciplina_id"
  end

  add_foreign_key "discentes", "turmas"
  add_foreign_key "docentes", "turmas"
  add_foreign_key "turmas", "disciplinas"
end
