class LinkRetrieval::TwitterWorker < ActiveJob::Base

	def perform(twitter_account_id)
		@account = TwitterAccount.find(twitter_account_id)
		@user = @account.user
		retrieve_user_tweets
		retrieve_network_tweets
	end

	def twitter_client
  	client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = ENV['TWITTER_KEY']
		  config.consumer_secret     = ENV['TWITTER_SECRET']
		  config.access_token        = @account.access_token
		  config.access_token_secret = @account.access_token_secret
		end
  end

  def retrieve_user_tweets
  	link_count = 0
		count = 0
		max_id = nil
		opts = {
			include_rts: true, 
			count: 200, 
			trim_user: true,
			exclude_replies: true,
			contributor_details: false,
			since_id: @account.link_posts.where(owned: true).order("posted_at DESC").first.try(:post_id)
		}.reject { |_,v| v.nil? }

		while count < 180 && link_count < 500
			count += 1
			account_tweets = twitter_client.user_timeline(@account.external_id.to_i, opts)
			break if account_tweets.empty?
			account_tweets.each do |tweet|
				tweet.urls.each do |url|
					begin
						url = Link.normalised_url(url.expanded_url.to_s)
						link = Link.find_or_create_by(url: url)
						puts "LINK ERRORS: #{link.errors.inspect}" if link.errors.any?
						if link.persisted?
							link_post = LinkPost.find_or_initialize_by(
								user: @user,
								link_id: link.try(:id),
								social_account: @account,
								source: :twitter,
								posted_at: tweet.created_at,
								posted_by: @account.username,
								post_id: tweet.id,
								owned: true
							)
							link_post.save
							link_count += 1
							puts "LINK POST ERRORS: #{link_post.errors.inspect}" if link_post.errors.any?
						end
					rescue => e
						Rails.logger.warn "Rescued exception while processing link: #{e}"
					end
				end
			end
			opts[:max_id] = account_tweets.last.id.to_i - 1
		end

  end

  def retrieve_network_tweets
  	link_count = 0
		count = 0
		max_id = nil
		opts = {
			include_rts: true, 
			count: 200, 
			trim_user: false,
			exclude_replies: true,
			contributor_details: true,
			include_entities: true,
			since_id: @account.link_posts.where(owned: false).order("posted_at DESC").first.try(:post_id)
		}.reject { |_,v| v.nil? }

		while count < 15 && link_count < 500
			count += 1
			network_tweets = twitter_client.home_timeline(opts)
			break if network_tweets.empty?
			network_tweets.each do |tweet|
				next if tweet.user.id.to_i == @account.external_id.to_i
				tweet.urls.each do |url|
					begin
						url = Link.normalised_url(url.expanded_url.to_s)
						link = Link.find_or_create_by(url: url)
						link_post = LinkPost.find_or_create_by(
							user: @user,
							link_id: link.try(:id),
							social_account: @account,
							posted_at: tweet.created_at,
							posted_by: tweet.user.screen_name,
							post_id: tweet.id,
							owned: false
						)
						link_count += 1
					rescue => e
						Rails.logger.warn "Rescues exception while processing link: #{e}"
					end
				end
			end
			opts[:max_id] = network_tweets.last.id.to_i - 1
		end
  end

end