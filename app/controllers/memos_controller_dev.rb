# frozen_string_literal: true

require 'pstore'

# data-file use ver. (non-database)
module CrudController
  def self.store_memos(storage)
    @pstore = PStore.new(storage)
  end

  def self.create_memo(title, body)
    memo = Memo.new(title, body)
    save_memo(memo)
  end

  def self.read_memo(id)
    @pstore.transaction(true) do
      memos = @pstore['memos'] || {}
      id == 'all' ? memos.values : memos.select { |k| k == id }.values.first
    end
  end

  def self.update_memo(title, body, id)
    memo = Memo.new(title, body, Time.now, id)
    save_memo(memo)
  end

  def self.delete_memo(id)
    @pstore.transaction do
      @pstore['memos'].delete(id)
    end
  end

  def self.save_memo(memo)
    @pstore.transaction do
      memos = @pstore['memos'] || {}
      memos[memo.id] = memo
      @pstore['memos'] = memos
    end
    memo
  end
end
