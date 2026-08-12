class DashboardsController < Web::BaseController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    render 'index_new'
  end
end
