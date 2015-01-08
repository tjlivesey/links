class LinkPost < ActiveRecord::Base
	belongs_to :link
	belongs_to :user

	validates :user_id, presence: true
	validates :link_id, presence: true, uniqueness: { scope: [:user_id, :owned] }, :if => :owned
	validates :posted_at, presence: true
	validates :post_id, presence: true

	scope :owned, ->{ where(owned: true )}
	scope :network, ->{ where(owned: false )}

end
