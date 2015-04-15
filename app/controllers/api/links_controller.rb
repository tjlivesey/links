class Api::LinksController < ApplicationController

	def index
		params[:filter] = "network" unless ["network", "self", "recommended"].include? params[:filter]
		if params[:filter] == "network"
			@link_posts = current_user.link_posts.network.order("posted_at DESC").limit(20).includes(:link)
		elsif params[:filter] == "self"
			@link_posts = current_user.link_posts.owned.order("posted_at DESC").limit(20).includes(:link)
		elsif params[:filter] == "recommended"
		end
	end

end