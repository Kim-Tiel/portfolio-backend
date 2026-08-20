module Api
  module V1
    class SessionsController < ApplicationController
      def create
        admin = ::Admin.find_by(email: params[:email]&.downcase)
        if admin&.authenticate(params[:password])
          admin.update(last_login_at: Time.current)
          render json: { token: issue_token(admin) }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end
    end
  end
end
