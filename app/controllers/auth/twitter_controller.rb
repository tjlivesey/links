class Auth::TwitterController < ApplicationController

	def auth
		request_token = client.authentication_request_token(oauth_callback: twitter_callback_url)
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

		twitter_account = TwitterAccount.find_or_initialize_by(twitter_id: access_token.params[:user_id])
		unless user = twitter_account.user
			user = current_user || User.create
			twitter_account.user = user
		end
		session[:user_id] = user.id

		twitter_account.access_token = access_token.token
		twitter_account.access_token_secret = access_token.secret
		twitter_account.username = access_token.params[:screen_name]
		twitter_account.image_url = access_token.params[:profile_image_url_https]
		twitter_account.save!
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
