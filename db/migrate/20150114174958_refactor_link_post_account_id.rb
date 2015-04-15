class RefactorLinkPostAccountId < ActiveRecord::Migration
  def change
  	remove_column :link_posts, :facebook_account_id, :integer
  	remove_column :link_posts, :google_account_id, :integer
  	remove_column :link_posts, :twitter_account_id, :integer
  	remove_column :link_posts, :linkedin_account_id, :integer

  	add_column :link_posts, :social_account_id, :integer
  	add_column :link_posts, :source, :string
  end
end
