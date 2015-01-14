class LinkSerializer < ActiveModel::Serializer
	attributes :url, 
		:title, 
		:description, 
		:image_url

	has_many :link_posts

end