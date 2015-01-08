class CreateLinkAssociations < ActiveRecord::Migration
  def change
    create_table :link_posts do |t|
    	t.belongs_to :link, index: true
    	t.belongs_to :user, index: true
    	t.text :sources, array: true, default: '{}'
    	t.boolean :owned, default: true, index: true
    	t.timestamp :posted_at
    	t.string :post_id
    	t.json :post_data
      t.timestamps null: false
    end
  end
end
