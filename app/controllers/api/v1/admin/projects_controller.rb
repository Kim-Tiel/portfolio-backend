module Api
  module V1
    module Admin
      class ProjectsController < BaseController
        before_action :set_project, only: %i[show update destroy]

        def index
          render json: Project.all.map { |p| ProjectSerializer.new(p).as_json }
        end

        def show
          render json: ProjectSerializer.new(@project).as_json
        end

        def create
          project = Project.new(project_params)
          if project.save
            render json: ProjectSerializer.new(project).as_json, status: :created
          else
            render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @project.update(project_params)
            render json: ProjectSerializer.new(@project).as_json
          else
            render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @project.destroy
          head :no_content
        end

        private

        def set_project
          @project = Project.find(params[:id])
        end

        def project_params
          params.require(:project).permit(
            :slug, :title, :client_type, :location, :summary, :description,
            :status, :site_url, :repo_url, :image_url, :is_featured, :sort_order,
            :started_on, :completed_on,
            skill_ids: [],
            project_metrics_attributes: %i[id label value sort_order _destroy]
          )
        end
      end
    end
  end
end
