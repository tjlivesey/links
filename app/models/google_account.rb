class GoogleAccount < ActiveRecord::Base
	include SocialAccount

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
		new_expiry = Time.zone.now + response['expires_in']
		update_attributes(
			access_token: response["access_token"],
			access_token_expiry: new_expiry
		)
	end

end
