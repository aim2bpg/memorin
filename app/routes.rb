# frozen_string_literal: true

require 'erubis'
require 'sinatra/base'
require_relative 'models/memo'

# main
class RoutesController < Sinatra::Base
  configure do
    enable :method_override
    set :erb, escape_html: true
    set :db_folder, File.expand_path(File.join(root, '..', 'db'))
    set :public_folder, File.expand_path(File.join(root, '..', 'public'))
  end

  configure :development do
    require_relative 'controllers/memos_controller_dev'
    CrudController.store_memos(File.join(settings.db_folder, 'datafile'))
  end

  configure :production do
    require_relative 'controllers/memos_controller'
    CrudController.connect_db('memos_db', 'memos_table')
  end

  get '/' do
    @memos = CrudController.read_memo('all')
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
    @memo = CrudController.read_memo(params[:id])
    erb :detail
  end

  get '/memos/:id/edit' do
    @memo = CrudController.read_memo(params[:id])
    erb :edit
  end

  patch '/memos/:id' do
    @memo = CrudController.update_memo(params[:title], params[:body], params[:id])
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
