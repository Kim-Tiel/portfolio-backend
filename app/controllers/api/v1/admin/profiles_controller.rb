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
          params.require(:profile).permit(
            :name, :title, :location, :timezone, :years_shipping,
            :completed_projects, :countries_worked_in, :employer_satisfaction,
            :avatar_url, :hero_tagline, available_for: []
          )
        end
      end
    end
  end
end
