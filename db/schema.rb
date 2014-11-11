# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140904202119) do

  create_table "projekties", force: true do |t|
    t.string   "nazwa"
    t.string   "stan"
    t.text     "opis"
    t.integer  "szafki_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projekty_uzytkownicies", id: false, force: true do |t|
    t.integer  "uzytkownicy_id"
    t.integer  "projekty_id"
    t.string   "rola"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "przedmioties", force: true do |t|
    t.string   "typ"
    t.string   "nazwa"
    t.string   "model"
    t.integer  "stan"
    t.integer  "uzytkownicy_id"
    t.integer  "szafki_id"
    t.integer  "projekty_id"
    t.text     "komentarz"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sesjas", force: true do |t|
    t.string   "klucz"
    t.integer  "uzytkownik_id"
    t.datetime "utworzenie"
  end

  create_table "szafkis", force: true do |t|
    t.string   "miejsce"
    t.integer  "numer"
    t.integer  "uzytkownicy_id"
    t.text     "komentarz"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uzytkownicies", force: true do |t|
    t.string   "nick"
    t.string   "email"
    t.string   "haslo"
    t.string   "haslo_salt"
    t.boolean  "reset_hasla"
    t.string   "status_czlonka"
    t.datetime "ostatnie_logowanie"
    t.integer  "poziom_dostepu"
    t.text     "komentarz"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
