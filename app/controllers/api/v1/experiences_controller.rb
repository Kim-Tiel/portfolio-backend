module Api
  module V1
    class ExperiencesController < ApplicationController
      def index
        experiences = Experience.includes(:experience_highlights, :skills)
        render json: experiences.map { |e| ExperienceSerializer.new(e).as_json }
      end
    end
  end
end
