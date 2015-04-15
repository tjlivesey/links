class Auth::OauthController < ApplicationController

	def auth
		csrf_token = SecureRandom.hex
		session["#{params[:site]}_csrf_token"] = csrf_token
		opts = account_class::OAUTH_OPTIONS.merge(
			state:  csrf_token,
			redirect_uri: oauth_callback_url(site: params[:site])
		)
		redirect_to client.auth_code.authorize_url(opts)
	end

	def callback
		if params[:state] != session["#{params[:site]}_csrf_token"]
			Rails.logger.warn "Possible #{params[:site]} CSRF detected for user: ##{current_user.id}"
			flash[:error] = "Error connecting account, please try again"
			redirect_to links_path
		else
			token = client.auth_code.get_token(params[:code], redirect_uri: oauth_callback_url(site: params[:site]))
			account = account_class.from_access_token(token)
			
			unless user = account.user
				user = current_user || User.create
				account.user = user
			end
			
			if account.save
				flash[:success] = "Success! Connected new account"
				session[:user_id] = user.id
			else
				flash[:error] = "Error connecting account, please try again"
			end
			redirect_to links_path
		end
	end

	private

	def account_class
		Object.const_get(params[:site].classify + "Account")
	end

	def client
		account_class.oauth_client
	end

end