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
          render :edit
        end
      end

      private

      def set_profile
        @profile = ::Profile.first_or_initialize
      end

      def profile_params
        permitted = params.require(:profile).permit(
          :first_name, :middle_name, :last_name, :title, :location, :timezone,
          :years_career_experience, :completed_projects, :employer_satisfaction,
          :avatar, :resume, :hero_tagline, :bio, :email, :linkedin_url, :github_url,
          :available_for, available_for: []
        )

        normalize_available_for(permitted)
      end

      # The form submits `available_for` as a comma-separated string; the
      # model expects an array, so split it here before assignment.
      def normalize_available_for(permitted)
        value = params.dig(:profile, :available_for)
        permitted[:available_for] = value.to_s.split(',').map(&:strip).reject(&:blank?) if value.is_a?(String)

        permitted
      end
    end
  end
end
