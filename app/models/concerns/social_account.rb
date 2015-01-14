module SocialAccount
	extend ActiveSupport::Concern

	included do
		belongs_to :user
		has_many :link_posts
		has_many :links, through: :link_posts
		after_commit :retrieve_links, on: :create
	end

	def retrieve_links
		klass = eval(self.class.name.split("Account").first + "::LinkRetrievalWorker")
		klass.perform_later(id)
	end

	def access_token_expired?
		self.respond_to?(:access_token_expiry) && access_token_expiry < Time.zone.now
	end

end