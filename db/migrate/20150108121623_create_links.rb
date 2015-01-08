class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
    	t.string :url
    	t.string :title
    	t.text :description
    	t.string :image_url
    	t.string :content_type
      t.timestamps null: false
    end
  end
end
