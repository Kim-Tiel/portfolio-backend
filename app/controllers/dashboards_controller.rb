class DashboardsController < Web::BaseController
  before_action :authenticate_admin!

  def index
    render 'index_new'
  end
end
