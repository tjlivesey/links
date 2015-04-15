class FacebookAccount < SocialAccount
	OAUTH_OPTIONS = {
		scope: "email friend_list"
	}

	def self.oauth_client
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

	def self.from_access_token(token)
		client = Koala::Facebook::API.new(token.token)
		profile = client.get_object("me")
		puts profile.inspect
		account = FacebookAccount.find_or_initialize_by(external_id: profile["id"])
		attrs = {
			access_token: token.token,
			access_token_expires_at: Time.at(token.expires_at),
			name: profile["first_name"] + " " + profile["last_name"],
			username: profile["first_name"] + " " + profile["last_name"],
			email: profile["email"],
			description: "Facebook account for #{profile['first_name']} #{profile['last_name']}",
			image_url: "https://graph.facebook.com/#{profile["id"]}/picture?type=square",
		}
		account.assign_attributes(attrs)
		account
	end
end
