module Web
  module Admin
    class ProfilesController < Web::BaseController
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
          flash.now[:alert] = 'Unable to save profile. Please check the form.'
          render :edit
        end
      end

      private

      def set_profile
        @profile = ::Profile.first_or_initialize
      end

      def profile_params
        params.require(:profile).permit(
          :name,
          :title,
          :location,
          :timezone,
          :years_shipping,
          :completed_projects,
          :countries_worked_in,
          :employer_satisfaction,
          { available_for: [] },
          :avatar_url,
          :hero_tagline
        )
      end
    end
  end
end
