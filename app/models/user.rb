class User < ActiveRecord::Base
	has_many :link_posts
	has_many :twitter_accounts
	has_many :facebook_accounts
	
	has_many :links, through: :link_posts do
		def owned
			where("link_posts.owned = ?", true)
		end

		def network
			where("link_posts.owned = ?", false)
		end
	end

end
