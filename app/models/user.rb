class User < ActiveRecord::Base
	has_many :link_posts
	
	has_many :links, through: :link_posts do
		def owned
			where("link_posts.owned = ?", true)
		end

		def network
			where("link_posts.owned = ?", false)
		end
	end

	after_commit :retrieve_links, on: :create

	private

	def retrieve_links
		LinkRetrivalWorker.perform_async(id)
	end

end
