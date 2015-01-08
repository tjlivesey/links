class LinkRetrievalWorker
	include Sidekiq::Worker

	def perform(user_id)
		user = User.find(user_id)
		# Twitter links

	end

end