class Twitter::LinkRetrievalWorker
	include Sidekiq::Worker

	def perform(user_id)
		@user = User.find(user_id)
		if @user.twitter_access_token
			retrieve_user_tweets
			retrieve_network_tweets
		end
	end

	def twitter_client
  	client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = ENV['TWITTER_KEY']
		  config.consumer_secret     = ENV['TWITTER_SECRET']
		  config.access_token        = @user.twitter_access_token
		  config.access_token_secret = @user.twitter_access_token_secret
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
			since_id: @user.link_posts.owned.where(source: :twitter).order("posted_at DESC").first.try(:post_id)
		}.reject { |_,v| v.nil? }

		while count < 180 && link_count < 3200
			count += 1
			user_tweets = twitter_client.user_timeline(@user.twitter_id.to_i, opts)
			break if user_tweets.empty?
			user_tweets.each do |tweet|
				tweet.urls.each do |url|
					begin
						url = Link.normalised_url(url.expanded_url.to_s)
						link = Link.find_or_create_by(url: url)
						link_post = LinkPost.find_or_initialize_by(
							user: @user,
							link: link,
							posted_at: tweet.created_at,
							post_id: tweet.id,
							owned: true
						)
						link_post.sources << :twitter
						link_post.save
						link_count += 1
					rescue => e
						Rails.logger.warn "Rescues exception while processing link: #{e}"
					end
				end
			end
			opts[:max_id] = user_tweets.last.id.to_i - 1
		end

  end

  def retrieve_network_tweets
  	link_count = 0
		count = 0
		max_id = nil
		opts = {
			include_rts: true, 
			count: 200, 
			trim_user: true,
			exclude_replies: true,
			contributor_details: false,
			include_entities: true,
			since_id: @user.link_posts.network.where(source: :twitter).order("posted_at DESC").first.try(:post_id)
		}.reject { |_,v| v.nil? }

		while count < 15 && link_count < 500
			count += 1
			network_tweets = twitter_client.home_timeline(opts)
			break if network_tweets.empty?
			network_tweets.each do |tweet|
				puts "SKIPPING OWN TWEET FROM TIMELINE" if tweet.user.id.to_i == @user.twitter_id.to_i
				next if tweet.user.id.to_i == @user.twitter_id.to_i
				tweet.urls.each do |url|
					begin
						url = Link.normalised_url(url.expanded_url.to_s)
						link = Link.find_or_create_by(url: url)
						puts link.errors.inspect unless link.valid?
						link_post = LinkPost.find_or_create_by(
							user: @user,
							link: link,
							source: :twitter,
							posted_at: tweet.created_at,
							post_id: tweet.id,
							owned: false
						)
						puts link_count.errors.inspect unless link.valid?
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