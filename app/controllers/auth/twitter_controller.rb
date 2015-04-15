class Auth::TwitterController < ApplicationController

	def auth
		request_token = TwitterAccount.oauth_client.authentication_request_token(oauth_callback: twitter_callback_url)
		session[:twitter_request_token] = request_token.token
		session[:twitter_request_token_secret] = request_token.secret
		redirect_to request_token.authorize_url
	end

	def callback
		access_token = TwitterAccount.oauth_client.authorize(
  		session[:twitter_request_token],
  		session[:twitter_request_token_secret],
  		:oauth_verifier => params[:oauth_verifier]
		)
		account = TwitterAccount.from_access_token(access_token)
		unless user = account.user
			user = current_user || User.create
			account.user = user
		end
		if account.save
			flash[:success] = "Success! Connected new account"
			session[:user_id] = user.id
		else
			flash[:error] = "Error connecting account, please try again"
		end
		redirect_to links_path
	end

end
