class Linkedin::LinkRetrievalWorker < ActiveJob::Base
	BASE_URL = "https://api.linkedin.com/v1"
	DEFAULT_OPTIONS = {
		query: {
			format: :json,
			count: 250,
			type: "SHAR"
		},
		format: :json
	}

	def perform(linkedin_account_id)
		@account = LinkedinAccount.find(linkedin_account_id)
		@user = @account.user
		retrieve_user_links
		retrieve_network_links
	end

	def retrieve_user_links
		opts = DEFAULT_OPTIONS.dup
		opts[:headers] = { "Authorization" => "Bearer #{@account.access_token}" }
		opts[:query][:scope] = :self
		if latest = @account.link_posts.where(owned: true).order("posted_at DESC").first
			opts[:query][:after] = latest.posted_at.to_i*1000
		end

		stream = HTTParty.get(BASE_URL + "/people/~/network/updates", opts).parsed_response
		stream["values"].each do |item|
			share = item["updateContent"]["person"]["currentShare"]
			url = share["content"]["submittedUrl"]
			url = Link.normalised_url(url)
			link = Link.find_or_initialize_by(url: url)
			link.save!
			link_post = LinkPost.find_or_initialize_by(
				user: @user,
				link_id: link.try(:id),
				linkedin_account: @account,
				posted_at: Time.at(share["timestamp"]/1000),
				post_id: share["id"],
				owned: true
			)
		end
	end

	def retrieve_network_links
		opts = DEFAULT_OPTIONS.dup
		opts[:headers] = { "Authorization" => "Bearer #{@account.access_token}" }
		if latest = @account.link_posts.where(owned: false).order("posted_at DESC").first
			opts[:query][:after] = latest.posted_at.to_i*1000
		end

		stream = HTTParty.get(BASE_URL + "/people/~/network/updates", opts).parsed_response
		stream["values"].each do |item|
			share = item["updateContent"]["person"]["currentShare"]
			next unless share && share["author"]["id"] != @account.linkedin_id
			begin
				url = share["content"]["submittedUrl"]
				url = Link.normalised_url(url)
				link = Link.find_or_create_by(url: url)
				puts link.errors.inspect unless link.valid?
				if link.persisted?
					link_post = LinkPost.find_or_initialize_by(
						user: @user,
						link_id: link.try(:id),
						linkedin_account: @account,
						posted_at: Time.at(share["timestamp"]/1000),
						posted_by: "#{share['author']['firstName']} #{share['author']['lastName']}",
						post_id: share["id"],
						owned: false
					)
					link_post.save
					link_post.errors.inspect unless link.valid?
				end
			rescue => e
				Rails.logger.warn "Rescued exception while processing link: #{e}"
			end
		end
	end

end