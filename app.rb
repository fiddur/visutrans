# encoding: utf-8
require 'sinatra'
require "sinatra/reloader"
require 'erubis'
require 'sinatra/flash'

class VisuTrans < Sinatra::Application
  class << self
    attr_accessor :neo_host
  end


  enable :sessions
  set :session_secret, 'ohvuSh3Athod3Aiw'
  set :public_folder, File.dirname(__FILE__) + '/static'

  register Sinatra::Reloader
  also_reload 'models/init.rb'


  register Sinatra::Flash

  configure :production do
    set :clean_trace, true
  end

  get '/' do
    erb :index, layout: :default
  end

  post '/categories/' do
    Category.create(
      name: params[:name]
      )

    # @todo Make categorizing use ajax :P
    redirect '/categorize_recipients'
  end
end

require_relative 'config.rb'
require_relative 'models/init'
#require_relative 'helpers/init'
require_relative 'routes/init'
