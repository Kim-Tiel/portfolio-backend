module Api
  module V1
    module Admin
      class ProfilesController < BaseController
        def show
          render json: ProfileSerializer.new(Profile.instance).as_json
        end

        def update
          profile = Profile.instance
          if profile.update(profile_params)
            render json: ProfileSerializer.new(profile).as_json
          else
            render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def profile_params
          permitted = params.require(:profile).permit(
            :name, :title, :location, :timezone, :years_career_experience,
            :completed_projects, :employer_satisfaction,
            :avatar_url, :hero_tagline, :available_for, available_for: []
          )

          available_for_value = params.dig(:profile, :available_for)
          if available_for_value.is_a?(String)
            permitted[:available_for] = available_for_value.to_s.split(',').map(&:strip).reject(&:blank?)
          end

          permitted
        end
      end
    end
  end
end
