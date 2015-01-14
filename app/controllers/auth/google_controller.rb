class Auth::GoogleController < ApplicationController

	def auth
		session[:google_csrf_token] = SecureRandom.hex
		redirect_to client.auth_code.authorize_url(
			scope: 'email https://www.googleapis.com/auth/plus.login',
			state:  session[:google_csrf_token],
			redirect_uri: google_callback_url,
			access_type: :offline,
			#approval_prompt: "force"
		)
	end

	def callback
		if params[:state] != session[:google_csrf_token]
			Rails.logger.warn "Possible Google+ CSRF detected for user: ##{current_user.id}"
			flash[:error] = "Error connecting your Google+ account, please try again"
			redirect_to links_path
    else          
      #Get token object, passing in the authorization code from the previous step 
      token = client.auth_code.get_token(params[:code], redirect_uri: google_callback_url)
      profile = HTTParty.get('https://www.googleapis.com/plus/v1/people/me', query: { access_token: token.token }).parsed_response
      google_account = GoogleAccount.find_or_initialize_by(google_id: profile["id"])
      unless user = google_account.user
				user = current_user || User.create
				google_account.user = user
			end
			session[:user_id] = user.id
			google_account.access_token = token.token
			google_account.refresh_token = token.refresh_token
			google_account.access_token_expiry = Time.at(token.expires_at)
			google_account.name = profile["displayName"]
			google_account.image_url = profile["image"]["url"]
			#google_account.email = profile["emails"].first.try(:[], "value")
			google_account.save!
			redirect_to links_path
  	end
	end

	private

	def client
    OAuth2::Client.new(
      ENV['GOOGLE_CLIENT_ID'], 
      ENV['GOOGLE_CLIENT_SECRET'], 
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token",
      site: "https://accounts.google.com"
     )
  end

end