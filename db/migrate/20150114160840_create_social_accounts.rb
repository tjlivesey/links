class CreateSocialAccounts < ActiveRecord::Migration
  def up
    create_table :social_accounts do |t|
    	t.string :type
    	t.string :external_id
    	t.string :access_token
    	t.string :access_token_secret
    	t.string :access_token_expires_at
    	t.string :refresh_token
    	t.string :email
    	t.string :name
    	t.string :image_url
    	t.string :user_id
    	t.string :username
    	t.string :description
      t.timestamps null: false
    end

    drop_table :google_accounts
  	drop_table :linkedin_accounts
  	drop_table :facebook_accounts
  	drop_table :twitter_accounts
  end

  def down
  	drop_table :social_accounts
  end

end
