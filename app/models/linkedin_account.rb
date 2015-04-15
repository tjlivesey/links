class LinkedinAccount < SocialAccount
	OAUTH_OPTIONS = {
		scope: 'r_basicprofile r_network rw_nus'
	}

	def self.oauth_client
		OAuth2::Client.new(
      ENV['LINKEDIN_KEY'], 
      ENV['LINKEDIN_SECRET'], 
      authorize_url: "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
      token_url: "/uas/oauth2/accessToken", #LinkedIn's access token path
      site: "https://www.linkedin.com"
    )
	end

	def self.from_access_token(token)
		opts = {
			headers: {
				'authorization' => "Bearer #{token.token}"
			},
			query: {
				format: :json
			}
		}
		profile = HTTParty.get('https://api.linkedin.com/v1/people/~:(id,first-name,last-name,headline,picture-url)', opts).parsed_response
    linkedin_account = LinkedinAccount.find_or_initialize_by(external_id: profile["id"])
    puts profile.inspect
    attrs = {
    	access_token: token.token,
    	access_token_expires_at: Time.at(token.expires_at),
    	name: profile["firstName"] + " " + profile["lastName"],
    	username: profile["firstName"] + " " + profile["lastName"],
    	description: profile["headline"],
    	image_url: profile["pictureUrl"],
    }
    linkedin_account.assign_attributes(attrs)
    linkedin_account
	end

end
