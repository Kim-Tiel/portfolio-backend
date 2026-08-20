module Web
  module Admin
    class AdminsController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!

      def index
        @admins = ::Admin.order(created_at: :desc)
      end

      def show
        @admin = ::Admin.find(params[:id])
      end
    end
  end
end
