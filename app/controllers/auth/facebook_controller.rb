class Auth::FacebookController < ApplicationController

	def auth
		session[:facebook_csrf_token] = SecureRandom.hex
		redirect_to client.auth_code.authorize_url(
			scope: 'email,friend_list',
			state:  session[:facebook_csrf_token],
			redirect_uri: facebook_callback_url
		)
	end

	def callback
		if params[:state] != session[:facebook_csrf_token]
			Rails.logger.warn "Possible Facebook CSRF detected for user: ##{current_user.id}"
			flash[:error] = "Error connecting your Facebook account, please try again"
			redirect_to links_path
    else    
			token = client.auth_code.get_token(params[:code], redirect_uri: facebook_callback_url)
			puts token.inspect

			client = Koala::Facebook::API.new(token.token)
			profile = client.get_object("me")

			facebook_account = FacebookAccount.find_or_initialize_by(facebook_id: profile["id"])
			unless user = facebook_account.user
				user = current_user || User.create
				facebook_account.user = user
			end
			session[:user_id] = user.id

			current_user.email = profile["email"] unless current_user.email
			facebook_account.access_token = token.token
			facebook_account.access_token_expiry = Time.at(token.expires_at)
			facebook_account.facebook_id = profile["id"]
			facebook_account.first_name = profile["first_name"]
			facebook_account.last_name = profile["last_name"]
			facebook_account.image_url = "https://graph.facebook.com/#{profile["id"]}/picture?type=square"
			facebook_account.save!
			current_user.save
			redirect_to links_path
		end
	end

	private

	def client
		# Response from facebook comes back as a query string format so need custom parser
		OAuth2::Response.register_parser(:facebook, 'text/plain') do |body|
      token_key, token_value, expiration_key, expiration_value = body.split(/[=&]/)
      {token_key => token_value, expiration_key => expiration_value, :mode => :query, :param_name => 'access_token'}
    end
    OAuth2::Client.new(
      ENV['FACEBOOK_APP_ID'], 
      ENV['FACEBOOK_APP_SECRET'], 
      authorize_url: "https://www.facebook.com/dialog/oauth?response_type=code",
      token_url: "https://graph.facebook.com/oauth/access_token"
     )
  end

end