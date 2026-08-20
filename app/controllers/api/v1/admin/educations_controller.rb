module Api
  module V1
    module Admin
      class EducationsController < BaseController
        before_action :set_education, only: %i[show update destroy]

        def index
          render json: Education.all.map { |e| EducationSerializer.new(e).as_json }
        end

        def show
          render json: EducationSerializer.new(@education).as_json
        end

        def create
          education = Education.new(education_params)
          if education.save
            render json: EducationSerializer.new(education).as_json, status: :created
          else
            render json: { errors: education.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @education.update(education_params)
            render json: EducationSerializer.new(@education).as_json
          else
            render json: { errors: @education.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @education.destroy
          head :no_content
        end

        private

        def set_education
          @education = Education.find(params[:id])
        end

        def education_params
          params.require(:education).permit(
            :institution, :degree, :field, :location, :start_date, :end_date,
            :is_graduated, :sort_order,
            education_milestones_attributes: %i[id occurred_on description sort_order _destroy]
          )
        end
      end
    end
  end
end
