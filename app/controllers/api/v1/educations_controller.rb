module Api
  module V1
    class EducationsController < ApplicationController
      def index
        education = Education.includes(:education_milestones)
        render json: education.map { |e| EducationSerializer.new(e).as_json }
      end
    end
  end
end
