class ChangeLinkPostsFields < ActiveRecord::Migration
  def change
  	remove_column :link_posts, :sources
  	add_column :link_posts, :facebook_account_id, :integer
  	add_column :link_posts, :twitter_account_id, :integer
  end
end
