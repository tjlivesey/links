module LinksHelper
	
	def date_change?(posts, current_index)
		if current_index == 0 || posts[current_index].posted_at.day != posts[current_index-1].posted_at.day
			true
		end
	end

end
