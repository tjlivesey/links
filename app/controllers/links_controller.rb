class LinksController < ApplicationController

	def index
		@posted_links = current_user.links.owned.order("posted_at DESC")
		@network_links = current_user.links.network.order("posted_at DESC")
	end

	def show
	end

end
