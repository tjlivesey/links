require 'open-uri'

class Link < ActiveRecord::Base
	belongs_to :user

	before_validation :populate_metadata

	validates :url, uniqueness: true, presence: true
	#validates :title, presence: true
	#validates :content_type, inclusion: { in: [:text, :video, :image] }

	def self.normalised_url(url)
		resolved_uri = HTTParty.get(url).request.uri

		uri = Addressable::URI.parse(resolved_uri)
		uri.scheme = "http"
		uri.normalize
		uri.fragment = nil
		# Strip UTM query params
		if uri.query
			query_hash = uri.query_values
			query_hash.reject! { |k,_| k =~ /utm/ }
			uri.query_values = query_hash
		end
		uri.to_s
	end

	def populate_metadata
		page = MetaInspector.new(url)
		unless page.response.status == 200
			errors.add(:url)
		end
		self.title = page.title
		self.description = page.description
		self.image_url = page.images.best
	end

end
