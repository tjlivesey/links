class LinkRetrieval::FacebookWorker < ActiveJob::Base

	def perform(facebook_account_id)
		@account = FacebookAccount.find(facebook_account_id)
		@user = @account.user
		retrieve_user_links
	end

	def facebook_client
		Koala::Facebook::API.new(@account.access_token)
	end

	def retrieve_user_links
		link_count = 0
		posts = facebook_client.get_connections("me", "links")

		while link_count < 500
			break if posts.nil?
			posts.each do |post|
				url = Addressable::URI.parse(post["link"])
				next if url.host.nil? || url.host =~ /facebook/
				url = Link.normalised_url(url.to_s)
				link = Link.find_or_create_by(url: url)
				puts "LINK ERRORS: #{link.errors.inspect}" if link.errors.any?
				if link.persisted?
					link_post = LinkPost.find_or_initialize_by(
						user: @user,
						link_id: link.try(:id),
						social_account: @account,
						source: :facebook,
						posted_at: Time.parse(post["created_time"]),
						post_id: post["id"],
						owned: true
					)
					link_post.save
					link_count += 1
					puts "LINK POST ERRORS: #{link_post.errors.inspect}" if link_post.errors.any?
				end
			end
			posts = posts.next_page
		end
	end

end