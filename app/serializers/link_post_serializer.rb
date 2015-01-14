class LinkPostSerializer < ActiveModel::Serializer
	attributes :url,
		:owned,
		:posted_at,
		:post_id,
		:posted_by

end