class FacebookAccount < ActiveRecord::Base
	belongs_to :user
	has_many :link_posts
	has_many :links, through: :link_posts

	after_commit :retrieve_links, on: :create

	private

	def retrieve_links
		Facebook::LinkRetrievalWorker.perform_later(id)
	end
end
