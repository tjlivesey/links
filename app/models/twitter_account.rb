class TwitterAccount < ActiveRecord::Base
	belongs_to :user

	after_commit :retrieve_links, on: :create
	has_many :link_posts

	def retrieve_links
		Twitter::LinkRetrievalWorker.perform_later(id)
	end

end
