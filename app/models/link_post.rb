class LinkPost < ActiveRecord::Base
	belongs_to :link
	belongs_to :user
	belongs_to :facebook_account
	belongs_to :twitter_account
	belongs_to :linkedin_account
	belongs_to :google_account

	validates :user_id, presence: true
	validates :link_id, presence: true
	validates :posted_at, presence: true
	validates :post_id, presence: true

	scope :owned, ->{ where(owned: true )}
	scope :network, ->{ where(owned: false )}
	scope :linkedin, ->{ where("linkedin_account_id is not NULL") }
	scope :facebook, ->{ where("facebook_account_id is not NULL") }
	scope :twitter, ->{ where("twitter_account_id is not NULL") }

	def source
	end
end