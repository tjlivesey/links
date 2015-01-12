class Google::LinkRetrievalWorker < ActiveJob::Base
	BASE_URL = 'https://www.googleapis.com/plus/v1'

	def perform(google_account_id)
		@account = GoogleAccount.find(google_account_id)
		@user = @account.user
		retrieve_user_links
	end

	def retrieve_user_links
		link_count = 0
		opts = {
			query: {
				maxResults: 100,
				access_token: @account.access_token
			}
		}
		latest = @account.link_posts.where(owned: true).order("posted_at DESC").first.try(:posted_at)
		while link_count < 500 do
			response = HTTParty.get(BASE_URL + "/people/me/activities/public", opts).parsed_response
			response["items"].each do |item|
				break if Time.parse(item['published']).to_i < latest.to_i
				begin
					item["object"]["attachments"].select { |attachment| attachment["objectType"] == "article" }.each do |article|
						url = Link.normalised_url(article["url"])
						link = Link.find_or_initialize_by(url: url)
						link.title = article["displayName"]
						link.image_url = article["image"]["url"]
						link.save
						puts "LINK ERRORS: #{link.errors.inspect}" if link.errors.any?
						
						if link.persisted?
							link_post = LinkPost.find_or_initialize_by(
								user: @user,
								link_id: link.try(:id),
								google_account: @account,
								posted_at: Date.parse(item['published']),
								post_id: item["id"],
								owned: true
							)
							link_post.save
							link_count += 1
							puts "LINK POST ERRORS: #{link_post.errors.inspect}" if link_post.errors.any?
						end
					end

				rescue => e
					Rails.logger.warn "Rescued exception while processing link: #{e}"
				end
			end
			if pagination = response["nextPageToken"]
				opts[:query][:nextPageToken] = token
			else
				break
			end
		end
	end

end