# frozen_string_literal: true

require 'digest'

# Memo model
class Memo
  attr_accessor :title, :body, :created_at, :id

  def initialize(
    title,
    body,
    created_at = Time.now,
    id = Digest::MD5.hexdigest(title + body + created_at.to_s)
  )
    @title = title
    @body = body
    @created_at = created_at
    @id = id
  end
end
