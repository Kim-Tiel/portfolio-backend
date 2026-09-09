module Api
  module V1
    module Admin
      class SkillsController < BaseController
        before_action :authenticate_admin!
        before_action :set_skill, only: %i[show update destroy update_icon destroy_icon]

        def index
          skills = paginate(Skill.all)
          render json: {
            data: skills.map { |s| SkillSerializer.new(s).as_json },
            meta: pagination_meta(skills)
          }
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

        def update_icon
          @skill.icon = params.require(:icon)
          if @skill.save
            render json: SkillSerializer.new(@skill).as_json
          else
            render json: { errors: @skill.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy_icon
          @skill.icon.purge
          render json: SkillSerializer.new(@skill).as_json
        end

        private

        def set_skill
          @skill = Skill.find(params[:id])
        end

        def skill_params
          params.require(:skill).permit(:name, :category, :proficiency, :proficiency_percent, :sort_order,
                                        :is_featured)
        end
      end
    end
  end
end
