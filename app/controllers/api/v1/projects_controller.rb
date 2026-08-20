module Api
  module V1
    class ProjectsController < ApplicationController
      def index
        projects = Project.includes(:skills, :project_metrics)
        projects = projects.featured if params[:featured] == 'true'
        render json: projects.map { |p| ProjectSerializer.new(p).as_json }
      end

      def show
        project = Project.includes(:skills, :project_metrics).find_by!(slug: params[:slug])
        render json: ProjectSerializer.new(project).as_json
      end
    end
  end
end
