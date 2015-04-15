class GoogleAccount < SocialAccount
	OAUTH_OPTIONS = {
		scope: 'email https://www.googleapis.com/auth/plus.login',
		access_type: :offline
	}

	def self.oauth_client
		OAuth2::Client.new(
      ENV['GOOGLE_CLIENT_ID'], 
      ENV['GOOGLE_CLIENT_SECRET'], 
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token",
      site: "https://accounts.google.com"
    )
	end

	def self.from_access_token(token)
		profile = HTTParty.get('https://www.googleapis.com/plus/v1/people/me', query: { access_token: token.token }).parsed_response
		puts token.inspect
		account = GoogleAccount.find_or_initialize_by(external_id: profile["id"])
		attrs = {
			access_token: token.token,
			refresh_token: token.refresh_token,
			access_token_expires_at: Time.at(token.expires_at),
			name: profile["displayName"],
			username: profile["displayName"],
			email: profile["emails"].first.try(:[], "value"),
			description: "Google+ account for #{profile['displayName']}",
			image_url: profile["image"]["url"]
		}.select { |_,v| !v.nil? 	}
		account.assign_attributes(attrs)
		account
	end

	def refresh_access_token
		url = "https://www.googleapis.com/oauth2/v3/token"
		opts = {
			query: {
				client_id:  ENV['GOOGLE_CLIENT_ID'],
				client_secret: ENV['GOOGLE_CLIENT_SECRET'],
				refresh_token: refresh_token,
				grant_type: "refresh_token"
			}
		}
		response = HTTParty.post(url, opts).parsed_response
		puts response.inspect
		new_expiry = Time.zone.now + response['expires_in']
		update_attributes(
			access_token: response["access_token"],
			access_token_expires_at: new_expiry
		)
	end

end
