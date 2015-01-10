class CreateTwitterAccounts < ActiveRecord::Migration
  def change
    create_table :twitter_accounts do |t|
    	t.string :twitter_id
    	t.string :username
    	t.string :access_token
    	t.string :access_token_secret
    	t.string :image_url
    	t.belongs_to :user
      t.timestamps null: false
    end

    remove_column :users, :twitter_id, :string
    remove_column :users, :twitter_username, :string
    remove_column :users, :twitter_access_token, :string
    remove_column :users, :twitter_access_token_secret, :string

  end
end
