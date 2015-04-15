class SocialAccount < ActiveRecord::Base
	belongs_to :user
	has_many :link_posts
	has_many :links, through: :link_posts
	#after_commit :retrieve_links, on: :create

	def access_token_expired?
		access_token_expires_at && access_token_expires_at < Time.zone.now
	end

	def retrieve_links
		type = self.class.name.split("Account").first
		Object.const_get("LinkRetrieval::#{type}Worker").perform_later(id)
	end

end
