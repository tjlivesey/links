class Auth::TwitterController < ApplicationController

	def auth
		request_token = client.authentication_request_token(oauth_callback: twitter_callback_path)
		session[:twitter_request_token] = request_token.token
		session[:twitter_request_token_secret] = request_token.secret
		redirect_to request_token.authorize_url
	end

	def callback
		access_token = client.authorize(
  		session[:twitter_request_token],
  		session[:twitter_request_token_secret],
  		:oauth_verifier => params[:oauth_verifier]
		)
		user = User.find_or_initialize_by(twitter_id: access_token.params[:user_id])
		user.twitter_access_token = access_token.token
		user.twitter_access_token_secret = access_token.secret
		user.twitter_username = access_token.params[:username]
		user.save!
		session[:user_id] = user.id
		redirect_to links_path
	end

	private

	def client
		@client ||= TwitterOAuth::Client.new(
    	consumer_key: ENV['TWITTER_KEY'],
    	consumer_secret: ENV['TWITTER_SECRET']
		)
	end

end
