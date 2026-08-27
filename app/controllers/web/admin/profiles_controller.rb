module Web
  module Admin
    class ProfilesController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!
      before_action :set_profile

      def show
        render :show
      end

      def edit
        render :edit
      end

      def update
        if @profile.update(profile_params)
          redirect_to admin_profile_path, notice: 'Profile updated successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save profile. Please check the form.'
=======
>>>>>>> origin/develop
          render :edit
        end
      end

      private

      def set_profile
        @profile = ::Profile.first_or_initialize
      end

      def profile_params
        permitted = params.require(:profile).permit(
          :name,
          :title,
          :location,
          :timezone,
          :years_career_experience,
          :completed_projects,
          :employer_satisfaction,
          :avatar_url,
          :hero_tagline,
          :available_for,
          { available_for: [] }
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
