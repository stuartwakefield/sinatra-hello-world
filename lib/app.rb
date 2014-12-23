require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require 'db'
require 'user'

class App < Sinatra::Application

  configure :development do
    register Sinatra::Reloader
  end

  set :show_exceptions, false

  db = Database.new
  
  # HATEOAS
  index_link = { rel: 'api.index', href: '/' }
  status_link = { rel: 'api.status', href: '/status' }
  users_list_link = { rel: 'users.list', href: '/users' }
  create_user_link = { rel: 'users.create', href: '/users', method: 'POST' }
  auth_link = { rel: 'auth', href: '/auth', method: 'POST' }

  before do
    content_type :json
  end

  get '/' do
    self_link = { rel: 'self', href: '/' }
    { links: [ self_link, status_link, users_list_link, create_user_link, auth_link ] }
  end

  get '/status' do
    self_link = { rel: 'self', href: '/status' }
    { links: [ self_link, index_link ] }
  end

  get '/users' do
    self_link = { rel: 'self', href: '/users' }
    { users: db.users.map { |user| User.new(user[:username]).to_hash }, links: [ self_link, create_user_link, index_link ] }
  end

  post '/users' do
    request.body.rewind
    data = JSON.parse request.body.read
    if db.add_user data
      User.new(data['username']).to_hash
    else
      status 400
      { error: 400, message: "Username Taken" }
    end
  end

  get '/users/:username' do |username|
    User.new(db.get_user(username)[:username]).to_hash
  end

  delete '/users' do
    db.delete_all
  end

  delete '/users/:username' do |username|
    db.delete_user username
  end

  post '/verify' do
    request.body.rewind
    data = JSON.parse request.body.read
    user = db.match data['username'], data['password']
    user.nil? ? { :verified => false } : { :user => user, :verified => true } 
  end

  not_found do
    { error: 404, message: 'Not Found' }
  end

  error do
    { error: response.status, message: 'Something Went Wrong' }
  end

  after do
    response.body = response.body.to_json
  end

end
