class AddPostedByToLinkPost < ActiveRecord::Migration
  def change
  	add_column :link_posts, :posted_by, :string
  end
end
