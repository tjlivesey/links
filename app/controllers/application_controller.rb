class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

  def current_user
  	@user ||= User.find_by(id: session[:user_id])
  end

  def twitter_client
  	client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = ENV['TWITTER_KEY']
		  config.consumer_secret     = ENV['TWITTER_SECRET']
		  config.access_token        = current_user.twitter_access_token
		  config.access_token_secret = current_user.twitter_access_token_secret
		end
  end

  

end
