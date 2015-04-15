class TwitterAccount < SocialAccount

	def self.oauth_client
		TwitterOAuth::Client.new(
    	consumer_key: ENV['TWITTER_KEY'],
    	consumer_secret: ENV['TWITTER_SECRET']
		)
	end

	def self.from_access_token(access_token)
		account = TwitterAccount.find_or_initialize_by(external_id: access_token.params[:user_id])
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = ENV['TWITTER_KEY']
		  config.consumer_secret     = ENV['TWITTER_SECRET']
		  config.access_token        = access_token.token
		  config.access_token_secret = access_token.secret
		end
		profile = client.verify_credentials
		attrs = {
			access_token: access_token.token,
			access_token_secret: access_token.secret,
			username: profile["screen_name"],
			name: profile["name"],
			image_url: profile["profile_image_url_https"],
			description: profile["description"]
		}
		account.assign_attributes(attrs)
		account
	end
end
