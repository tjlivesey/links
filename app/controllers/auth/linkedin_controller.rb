class Auth::LinkedinController < ApplicationController

	def auth
		session[:linkedin_csrf_token] = SecureRandom.hex
		redirect_to client.auth_code.authorize_url(
			scope: 'r_basicprofile r_network rw_nus',
			state:  session[:linkedin_csrf_token],
			redirect_uri: linkedin_callback_url
		)
	end

	def callback
		if params[:state] != session[:linkedin_csrf_token]
			Rails.logger.warn "Possible LinkedIn CSRF detected for user: ##{current_user.id}"
			flash[:error] = "Error connecting your LinkedIn account, please try again"
			redirect_to links_path
    else          
      #Get token object, passing in the authorization code from the previous step 
      token = client.auth_code.get_token(params[:code], redirect_uri: linkedin_callback_url)

      access_token = OAuth2::AccessToken.new(client, token.token, {
        mode: :header,
        header_format:'Bearer %s',
      })
      response = access_token.get('https://api.linkedin.com/v1/people/~:(id,first-name,last-name,headline,picture-url)?format=json')
      profile = JSON.parse(response.body)

      linkedin_account = LinkedinAccount.find_or_initialize_by(linkedin_id: profile["id"])
      unless user = linkedin_account.user
				user = current_user || User.create
				linkedin_account.user = user
			end
			session[:user_id] = user.id
			linkedin_account.access_token = token.token
			linkedin_account.access_token_expiry = Time.at(token.expires_at)
			linkedin_account.first_name = profile["firstName"]
			linkedin_account.last_name = profile["lastName"]
			linkedin_account.headline = profile["headline"]
			linkedin_account.image_url = profile["pictureUrl"]
			linkedin_account.save!
			redirect_to links_path
  	end
	end

	private

	def client
    OAuth2::Client.new(
      ENV['LINKEDIN_KEY'], 
      ENV['LINKEDIN_SECRET'], 
      authorize_url: "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
      token_url: "/uas/oauth2/accessToken", #LinkedIn's access token path
      site: "https://www.linkedin.com"
     )
  end

end