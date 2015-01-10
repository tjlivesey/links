class Facebook::LinkRetrievalWorker < ActiveJob::Base

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

		while link_count < 3000
			break if posts.nil?
			posts.each do |post|
				url = Addressable::URI.parse(post["link"])
				puts "URL: #{url.to_s} \n \n"

				next if url.host.nil? || url.host =~ /facebook/
				url = Link.normalised_url(url.to_s)
				link = Link.find_or_create_by(url: url)
				puts "LINK ERRORS: #{link.errors.inspect}" if link.errors.any?
				link_post = LinkPost.find_or_initialize_by(
					user: @user,
					link: link,
					facebook_account: @account,
					posted_at: Time.parse(post["created_time"]),
					post_id: post["id"],
					owned: true
				)
				link_post.save
				puts "LINK POST ERRORS: #{link_post.errors.inspect}" if link_post.errors.any?
				link_count += 1
			end
			posts = posts.next_page
		end
	end

end