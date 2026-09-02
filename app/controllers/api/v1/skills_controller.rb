module Api
  module V1
    class SkillsController < ApplicationController
      def index
        skills = Skill.all
        skills = skills.featured if params[:featured] == 'true'
        render json: skills.map { |s| SkillSerializer.new(s).as_json }
      end
    end
  end
end
