class AddRefreshTokenToSocialAccounts < ActiveRecord::Migration
  def change
  	add_column :google_accounts, :refresh_token, :string
  	add_column :google_accounts, :access_token_expiry, :datetime

  	add_column :facebook_accounts, :access_token_expiry, :datetime
  	add_column :linkedin_accounts, :access_token_expiry, :datetime  	

  end
end
