class Auth::FacebookController < ApplicationController

	def auth
		redirect_to oauth_client.url_for_oauth_code(scope: "email,friend_list")
	end

	def callback
		token = oauth_client.get_access_token(params[:code])
		client = Koala::Facebook::API.new(token)
		profile = client.get_object("me")

		facebook_account = FacebookAccount.find_or_initialize_by(facebook_id: profile["id"])
		unless user = facebook_account.user
			user = current_user || User.create
			facebook_account.user = user
		end
		session[:user_id] = user.id

		current_user.email = profile["email"] unless current_user.email
		facebook_account.access_token = token
		facebook_account.facebook_id = profile["id"]
		facebook_account.first_name = profile["first_name"]
		facebook_account.last_name = profile["last_name"]
		facebook_account.image_url = "https://graph.facebook.com/#{profile["id"]}/picture?type=square"
		facebook_account.save!
		current_user.save
		redirect_to links_path
	end

	def oauth_client
		Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], facebook_callback_url)
	end

end