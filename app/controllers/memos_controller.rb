# frozen_string_literal: true

require 'pg'

# data-base use ver.
module CrudController
  def self.connect_db(db_name, table_name)
    @conn = PG.connect(dbname: db_name)
    @table_name = table_name
    create_table unless table_exist?
  end

  def self.create_memo(title, body)
    memo = Memo.new(title, body)
    prepare_name = 'create_memo'
    delete_if_exist(prepare_name)
    create_memo_query = "INSERT INTO #{@table_name} (id, title, body, created_at) VALUES ($1, $2, $3, $4)"
    @conn.prepare(prepare_name, create_memo_query)
    @conn.exec_prepared(prepare_name, [memo.id, title, body, memo.created_at])
    memo
  end

  # rubocop warning 'Method has too many lines. [xx/10]',so I split it.
  def self.read_memo(id)
    id == 'all' ? read_all_memo : read_one_memo(id)
  end

  def self.read_all_memo
    prepare_name = 'read_memo'
    delete_if_exist(prepare_name)
    read_all_query = "SELECT * FROM #{@table_name}"
    @conn.prepare(prepare_name, read_all_query)
    memos = []
    @conn.exec_prepared(prepare_name).each do |memo|
      memos << Memo.new(memo['title'], memo['body'], memo['created_at'], memo['id'])
    end
    memos
  end

  def self.read_one_memo(id)
    prepare_name = 'read_memo'
    delete_if_exist(prepare_name)
    read_memo_query = "SELECT * FROM #{@table_name} WHERE id = $1"
    @conn.prepare(prepare_name, read_memo_query)
    memo = @conn.exec_prepared(prepare_name, [id]).first
    Memo.new(memo['title'], memo['body'], memo['created_at'], memo['id'])
  end

  def self.update_memo(title, body, id)
    memo = Memo.new(title, body, Time.now, id)
    prepare_name = 'update_memo'
    delete_if_exist(prepare_name)
    update_memo_query = "UPDATE #{@table_name} SET (title, body, created_at) = ($2, $3, $4) WHERE id = $1"
    @conn.prepare(prepare_name, update_memo_query)
    @conn.exec_prepared(prepare_name, [id, title, body, memo.created_at])
    memo
  end

  def self.delete_memo(id)
    prepare_name = 'delete_memo'
    delete_if_exist(prepare_name)
    delete_memo_query = "DELETE FROM #{@table_name} WHERE id = $1"
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
    exist_table_query = "SELECT table_name FROM information_schema.tables WHERE table_name = '#{@table_name}'"
    @conn.prepare(prepare_name, exist_table_query)
    @conn.exec_prepared(prepare_name).cmd_tuples == 1
  end

  def self.create_table
    prepare_name = 'create_table'
    delete_if_exist(prepare_name)
    create_table_query = "CREATE TABLE #{@table_name} (id TEXT NOT NULL, title TEXT NOT NULL, body TEXT NOT NULL,
                          created_at timestamp with time zone)"
    @conn.prepare(prepare_name, create_table_query)
    @conn.exec_prepared(prepare_name)
  end
end
