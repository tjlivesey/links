class CreateGoogleAccounts < ActiveRecord::Migration
  def change
    create_table :google_accounts do |t|
    	t.string :google_id
    	t.string :access_token
    	t.string :image_url
    	t.string :name
    	t.string :email
    	t.belongs_to :user
      t.timestamps null: false
    end
  end
end