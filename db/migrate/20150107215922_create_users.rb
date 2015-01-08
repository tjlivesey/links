class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string :twitter_id
    	t.string :twitter_username
    	t.string :twitter_access_token
    	t.string :twitter_access_token_secret
    	t.string :email
      t.timestamps null: false
    end
  end
end
