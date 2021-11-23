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

ActiveRecord::Schema.define(version: 2021_11_22_093453) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "article_type", ["article", "podcast", "unknown"]

  create_table "articles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "title"
    t.text "url"
    t.text "remote_id"
    t.text "description"
    t.text "author"
    t.datetime "pub_date", precision: 6
    t.boolean "star"
    t.datetime "read", precision: 6
    t.json "itunes"
    t.enum "kind", default: "article", enum_type: "article_type"
    t.uuid "feed_id", null: false
    t.tsvector "tsv_description"
    t.tsvector "tsv_title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feed_id", "remote_id"], name: "index_articles_on_feed_id_and_remote_id", unique: true
    t.index ["feed_id"], name: "index_articles_on_feed_id"
  end

  create_table "articles_tags", id: false, force: :cascade do |t|
    t.uuid "article_id", null: false
    t.uuid "tag_id", null: false
  end

  create_table "directories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "title"
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.index ["ancestry"], name: "index_directories_on_ancestry"
    t.index ["user_id"], name: "index_directories_on_user_id"
  end

  create_table "feeds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "title"
    t.text "url"
    t.text "link"
    t.text "icon"
    t.text "description"
    t.json "error"
    t.uuid "directory_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "properties"
    t.index ["directory_id"], name: "index_feeds_on_directory_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "articles", "feeds"
  add_foreign_key "directories", "users"
  add_foreign_key "feeds", "directories"
  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute(<<-SQL)
CREATE OR REPLACE FUNCTION public.articles_before_insert_update_row_tr()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    new.tsv_description := to_tsvector('pg_catalog.english', coalesce(new.description,''));
    new.tsv_title := to_tsvector('pg_catalog.english', coalesce(new.title,''));
    RETURN NEW;
END;
$function$
  SQL

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute("CREATE TRIGGER articles_before_insert_update_row_tr BEFORE INSERT OR UPDATE ON \"articles\" FOR EACH ROW EXECUTE FUNCTION articles_before_insert_update_row_tr()")

end
