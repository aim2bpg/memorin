# frozen_string_literal: true

require 'erubis'
require 'sinatra/base'
require_relative 'models/memo'
require_relative 'controllers/memos_controller'

# main
class RoutesController < Sinatra::Base
  configure do
    enable :method_override
    set :erb, escape_html: true
    set :db_folder, File.expand_path(File.join(root, '..', 'db'))
    set :public_folder, File.expand_path(File.join(root, '..', 'public'))
    CrudController.connect_db
  end

  get '/' do
    @memos = CrudController.read_all_memo
    erb :index
  end

  get '/memos/new' do
    erb :new
  end

  post '/memos' do
    @memo = CrudController.create_memo(params[:title], params[:body])
    redirect to("/memos/#{@memo.id}")
  end

  get '/memos/:id' do
    @memo = CrudController.read_one_memo(params[:id])
    erb :detail
  end

  get '/memos/:id/edit' do
    @memo = CrudController.read_one_memo(params[:id])
    erb :edit
  end

  patch '/memos/:id' do
    @memo = CrudController.update_memo(params[:id], params[:title], params[:body])
    erb :detail
  end

  delete '/memos/:id' do
    CrudController.delete_memo(params[:id])
    redirect to('/')
  end

  not_found do
    send_file File.join(settings.public_folder, '404.html')
  end
end
