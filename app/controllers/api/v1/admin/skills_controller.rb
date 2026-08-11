module Api
  module V1
    module Admin
      class SkillsController < BaseController
        before_action :set_skill, only: %i[show update destroy]

        def index
          render json: Skill.all.map { |s| SkillSerializer.new(s).as_json }
        end

        def show
          render json: SkillSerializer.new(@skill).as_json
        end

        def create
          skill = Skill.new(skill_params)
          if skill.save
            render json: SkillSerializer.new(skill).as_json, status: :created
          else
            render json: { errors: skill.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @skill.update(skill_params)
            render json: SkillSerializer.new(@skill).as_json
          else
            render json: { errors: @skill.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @skill.destroy
          head :no_content
        end

        private

        def set_skill
          @skill = Skill.find(params[:id])
        end

        def skill_params
          params.require(:skill).permit(:name, :category, :proficiency, :icon_slug, :sort_order)
        end
      end
    end
  end
end
