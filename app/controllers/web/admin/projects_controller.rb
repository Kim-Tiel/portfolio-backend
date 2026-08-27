module Web
  module Admin
    class ProjectsController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!
      before_action :set_project, only: %i[show edit update destroy]

      def index
        @projects = Project.order(sort_order: :asc)
      end

      def show; end

      def new
        @project = Project.new
        build_metric_rows
      end

      def create
        @project = Project.new(project_params)
        if @project.save
          redirect_to admin_project_path(@project), notice: 'Project created successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save project. Please check the form.'
=======
>>>>>>> origin/develop
          build_metric_rows
          render :new
        end
      end

      def edit
        build_metric_rows
      end

      def update
        if @project.update(project_params)
          redirect_to admin_project_path(@project), notice: 'Project updated successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save project. Please check the form.'
=======
>>>>>>> origin/develop
          build_metric_rows
          render :edit
        end
      end

      def destroy
        @project.destroy
        redirect_to admin_projects_path, notice: 'Project removed successfully.'
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        params.require(:project).permit(
          :slug,
          :title,
          :client_type,
          :location,
          :summary,
          :description,
          :status,
          :site_url,
          :repo_url,
          :image_url,
          :is_featured,
          :sort_order,
          :started_on,
          :completed_on,
          project_metrics_attributes: %i[id label value sort_order _destroy]
        )
      end

      def build_metric_rows
        (3 - @project.project_metrics.size).times { @project.project_metrics.build }
      end
    end
  end
end
