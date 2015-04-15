class LinkPost < ActiveRecord::Base
	belongs_to :link
	belongs_to :user
	belongs_to :social_account

	validates :user_id, presence: true
	validates :link_id, presence: true
	validates :posted_at, presence: true
	validates :post_id, presence: true

	scope :owned, ->{ where(owned: true )}
	scope :network, ->{ where(owned: false )}

	def source
		return 
	end
end