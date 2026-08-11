module Api
  module V1
    class SkillsController < ApplicationController
      def index
        render json: Skill.all.map { |s| SkillSerializer.new(s).as_json }
      end
    end
  end
end
