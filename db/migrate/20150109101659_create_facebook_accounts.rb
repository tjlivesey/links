class CreateFacebookAccounts < ActiveRecord::Migration
  def change
    create_table :facebook_accounts do |t|
    	t.string :facebook_id
    	t.string :access_token
    	t.string :first_name
    	t.string :last_name
    	t.string :email
    	t.string :image_url
    	t.belongs_to :user
      t.timestamps null: false
    end
    remove_column :users, :facebook_id
    remove_column :users, :facebook_access_token
  end
end
