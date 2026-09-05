module Api
  module V1
    module Admin
      class ExperiencesController < BaseController
        before_action :set_experience, only: %i[show update destroy]

        def index
          experiences = paginate(Experience.all)
          render json: {
            data: experiences.map { |e| ExperienceSerializer.new(e).as_json },
            meta: pagination_meta(experiences)
          }
        end

        def show
          render json: ExperienceSerializer.new(@experience).as_json
        end

        def create
          experience = Experience.new(experience_params)
          if experience.save
            render json: ExperienceSerializer.new(experience).as_json, status: :created
          else
            render json: { errors: experience.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @experience.update(experience_params)
            render json: ExperienceSerializer.new(@experience).as_json
          else
            render json: { errors: @experience.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @experience.destroy
          head :no_content
        end

        private

        def set_experience
          @experience = Experience.find(params[:id])
        end

        def experience_params
          params.require(:experience).permit(
            :company, :role, :location, :is_remote, :start_date, :end_date,
            :commit_hash, :sort_order,
            skill_ids: [],
            experience_highlights_attributes: %i[id text sort_order _destroy]
          )
        end
      end
    end
  end
end
