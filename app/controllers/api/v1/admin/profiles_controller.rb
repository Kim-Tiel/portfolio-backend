module Api
  module V1
    module Admin
      class ProfilesController < BaseController
        before_action :authenticate_admin!, only: %i[update update_avatar destroy_avatar update_resume destroy_resume]

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

        def update_avatar
          profile = Profile.instance
          profile.avatar = params.require(:avatar)
          if profile.save
            render json: ProfileSerializer.new(profile).as_json
          else
            render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy_avatar
          profile = Profile.instance
          profile.avatar.purge
          render json: ProfileSerializer.new(profile).as_json
        end

        def update_resume
          profile = Profile.instance
          profile.resume = params.require(:resume)
          if profile.save
            render json: ProfileSerializer.new(profile).as_json
          else
            render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy_resume
          profile = Profile.instance
          profile.resume.purge
          render json: ProfileSerializer.new(profile).as_json
        end

        private

        def profile_params
          permitted = params.require(:profile).permit(
            :first_name, :middle_name, :last_name, :title, :location, :timezone,
            :years_career_experience, :completed_projects, :employer_satisfaction,
            :hero_tagline, :bio, :email, :linkedin_url, :github_url,
            :available_for, available_for: []
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
