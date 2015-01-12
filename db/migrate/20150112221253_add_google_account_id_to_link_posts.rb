class AddGoogleAccountIdToLinkPosts < ActiveRecord::Migration
  def change
  	add_column :link_posts, :google_account_id, :integer
  end
end
