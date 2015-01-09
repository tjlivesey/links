class Auth::FacebookController < ApplicationController

	def auth
		redirect_to oauth_client.url_for_oauth_code(scope: "email,friend_list")
	end

	def callback
		token = oauth_client.get_access_token(params[:code])
		current_user.update_attributes(facebook_access_token: token)
		client = Koala::Facebook::API.new(token)
		profile = client.get_object("me")
		current_user.email = profile["email"] unless current_user.email
		current_user.facebook_id = profile["id"]
		current_user.save
		redirect_to links_path
	end

	def oauth_client
		Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], facebook_callback_url)
	end

end