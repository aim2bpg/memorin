# frozen_string_literal: true

require 'pg'

# data-base use ver.
module CrudController
  DB_NAME = 'memos_db'
  TABLE_NAME = 'memos_table'

  def self.connect_db
    @conn = PG.connect(dbname: DB_NAME)
    create_table unless table_exist?
  end

  def self.create_memo(title, body)
    memo = Memo.new(title, body)
    prepare_name = 'create_memo'
    delete_if_exist(prepare_name)
    create_memo_query =
      "INSERT INTO #{TABLE_NAME} (id, title, body, created_at, updated_at) VALUES ($1, $2, $3, $4, $5)"
    @conn.prepare(prepare_name, create_memo_query)
    @conn.exec_prepared(prepare_name, [memo.id, title, body, memo.created_at, memo.updated_at])
    memo
  end

  def self.read_all_memo
    prepare_name = 'read_all_memo'
    delete_if_exist(prepare_name)
    read_all_query = "SELECT * FROM #{TABLE_NAME}"
    @conn.prepare(prepare_name, read_all_query)
    memos = []
    @conn.exec_prepared(prepare_name).each do |memo|
      memos << Memo.new(memo['title'], memo['body'], memo['created_at'], memo['id'], memo['updated_at'])
    end
    memos
  end

  def self.read_one_memo(id)
    prepare_name = 'read_one_memo'
    delete_if_exist(prepare_name)
    read_memo_query = "SELECT * FROM #{TABLE_NAME} WHERE id = $1"
    @conn.prepare(prepare_name, read_memo_query)
    memo = @conn.exec_prepared(prepare_name, [id]).first
    Memo.new(memo['title'], memo['body'], memo['created_at'], memo['id'], memo['updated_at'])
  end

  def self.update_memo(id, title, body)
    memo = Memo.new(title, body, read_one_memo(id).created_at, id)
    prepare_name = 'update_memo'
    delete_if_exist(prepare_name)
    update_memo_query = "UPDATE #{TABLE_NAME} SET (title, body, updated_at) = ($2, $3, $4) WHERE id = $1"
    @conn.prepare(prepare_name, update_memo_query)
    @conn.exec_prepared(prepare_name, [id, title, body, memo.updated_at])
    memo
  end

  def self.delete_memo(id)
    prepare_name = 'delete_memo'
    delete_if_exist(prepare_name)
    delete_memo_query = "DELETE FROM #{TABLE_NAME} WHERE id = $1"
    @conn.prepare(prepare_name, delete_memo_query)
    @conn.exec_prepared(prepare_name, [id])
  end

  def self.prepare_exist?(prepare_name)
    tuple = @conn.exec("SELECT * FROM pg_prepared_statements WHERE name='#{prepare_name}'").cmd_tuples
    tuple.positive?
  end

  def self.delete_if_exist(prepare_name)
    @conn.exec("DEALLOCATE #{prepare_name}") if prepare_exist?(prepare_name)
  end

  def self.table_exist?
    prepare_name = 'table_exist'
    delete_if_exist(prepare_name)
    exist_table_query = "SELECT table_name FROM information_schema.tables WHERE table_name = '#{TABLE_NAME}'"
    @conn.prepare(prepare_name, exist_table_query)
    @conn.exec_prepared(prepare_name).cmd_tuples == 1
  end

  def self.create_table
    prepare_name = 'create_table'
    delete_if_exist(prepare_name)
    create_table_query = "CREATE TABLE #{TABLE_NAME} (id TEXT NOT NULL, title TEXT NOT NULL, body TEXT NOT NULL,
                          created_at timestamp with time zone, updated_at timestamp with time zone)"
    @conn.prepare(prepare_name, create_table_query)
    @conn.exec_prepared(prepare_name)
  end
end
