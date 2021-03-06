require 'open-uri'

class Link < ActiveRecord::Base
	belongs_to :user
	has_many :link_posts

	before_validation :populate_metadata

	validates :url, uniqueness: true, presence: true
	validates :title, presence: true

	def self.normalised_url(url)
		resolved_uri = MetaInspector.new(url).url
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
		uri.to_s.gsub(/\?\z/, "")
	end

	def populate_metadata
		page = MetaInspector.new(url)
		errors.add(:url) unless page.response.status < 400
		errors.add(:content_type) unless page.content_type == "text/html"
		if page.title.blank?
			self.title = self.title || page.host
		else
			self.title = page.title
		end
		self.description = self.description || page.description 
		self.image_url = self.image_url || page.images.best
	end

	def host
		Addressable::URI.parse(url).host
	end

end
