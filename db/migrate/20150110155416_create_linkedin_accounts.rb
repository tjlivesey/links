class CreateLinkedinAccounts < ActiveRecord::Migration
  def change
    create_table :linkedin_accounts do |t|
    	t.string :linkedin_id
    	t.string :access_token
    	t.string :first_name
    	t.string :last_name
    	t.string :headline
    	t.string :image_url
    	t.belongs_to :user
      t.timestamps null: false
    end

    add_column :link_posts, :linkedin_account_id, :integer
  end
end
