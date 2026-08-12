module Web
  module Admin
    class ResourcesController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!
      ALLOWED_MODELS = %w[Admin Skill Project Experience Education ContactMessage MemoryLogEntry Profile]

      def index
        resource = params[:resource].to_s
        model_name = resource.singularize.camelize
        unless ALLOWED_MODELS.include?(model_name)
          return redirect_to dashboard_path, alert: 'Resource not allowed'
        end

        @model_name = model_name
        @model = @model_name.safe_constantize
        @records = @model.order(created_at: :desc).limit(200)
      end

      def show
        resource = params[:resource].to_s
        model_name = resource.singularize.camelize
        unless ALLOWED_MODELS.include?(model_name)
          return redirect_to dashboard_path, alert: 'Resource not allowed'
        end

        @model_name = model_name
        @model = @model_name.safe_constantize
        @record = @model.find(params[:id])
      end
    end
  end
end
