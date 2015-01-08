class Facebook::LinkRetrievalWorker
	include Sidekiq::Worker

	def perform(user_id)
		@user = User.find(user_id)
		if @user.facebook_access_token
			retrieve_user_links
		end
	end

	def facebook_client
		Koala::Facebook::API.new(@user.facebook_access_token)
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
				puts link.errors.inspect
				link_post = LinkPost.find_or_initialize_by(
					user: @user,
					link: link,
					posted_at: Time.parse(post["created_time"]),
					post_id: post["id"],
					owned: true
				)
				link_post.sources << "facebook" unless link_post.sources.include?("facebook")
				link_post.save
				puts link_post.errors.inspect
				link_count += 1
			end
			posts = posts.next_page
		end
	end

end