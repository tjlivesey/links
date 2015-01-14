class LinkRetrievalScheduler
	include Sidekiq::Worker
	include Sidetiq::Schedulable

	recurrence { hourly.minute_of_hour(0, 15, 30, 45) }

	def perform
		TwitterAccount.all.each(&:retrieve_links)
		GoogleAccount.all.each(&:retrieve_links)
		FacebookAccount.all.each(&:retrieve_links)
		LinkedinAccount.all.each(&:retrieve_links)
	end

end