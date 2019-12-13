require './config/environment'
require 'rack-flash'

class ApplicationController < Sinatra::Base

  configure do
    set :views, 'app/views'
    enable :sessions
    use Rack::Flash, :sweep => true
    set :session_secret, "password_security"
  end

  get "/" do
    if logged_in?
      @user = current_user
      erb :welcome
    else
      erb :welcome
    end
  end

  get "/search" do
    redirect_if_not_logged_in
    erb :search
  end

  get '/login' do
    erb :login
  end

  get '/logout' do
    session.clear
    erb :logout
  end

  post '/login' do
    # Find the user with this username
    @user = Account.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.user_id
      redirect to "/"
    else
      @error = ["Invalid username or password"]
      erb :failure
    end
  end

# HELPER METHODS

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def redirect_if_not_logged_in
      unless logged_in?
        flash[:notice] = "Please login to continue."
        flash[:notice]
        redirect to '/login'
      end
    end

    def redirect_if_cannot_edit(model_id)
      unless model_id == current_user.id
        flash[:notice] = "Permission Denied."
        flash[:notice]
        redirect to "/users"
      end
    end

    def current_user
      User.find(session[:user_id])
    end
  end

  # PRIVATE METHODS
  private

  def user_params
    { username: params[:username], password: params[:password] }
  end

end
