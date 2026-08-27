module Web
  module Admin
    class ExperiencesController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!
      before_action :set_experience, only: %i[show edit update destroy]

      def index
        @experiences = Experience.all
      end

      def show; end

      def new
        @experience = Experience.new
        build_highlight_rows
      end

      def create
        @experience = Experience.new(experience_params)
        if @experience.save
          redirect_to admin_experience_path(@experience), notice: 'Experience created successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save experience. Please check the form.'
=======
>>>>>>> origin/develop
          build_highlight_rows
          render :new
        end
      end

      def edit
        build_highlight_rows
      end

      def update
        if @experience.update(experience_params)
          redirect_to admin_experience_path(@experience), notice: 'Experience updated successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save experience. Please check the form.'
=======
>>>>>>> origin/develop
          build_highlight_rows
          render :edit
        end
      end

      def destroy
        @experience.destroy
        redirect_to admin_experiences_path, notice: 'Experience removed successfully.'
      end

      private

      def set_experience
        @experience = Experience.find(params[:id])
      end

      def experience_params
        params.require(:experience).permit(
          :company, :role, :location, :is_remote, :start_date, :end_date,
<<<<<<< HEAD
          :commit_hash, :sort_order, skill_ids: [], experience_highlights_attributes: %i[id text sort_order _destroy]
=======
          :sort_order, skill_ids: [], experience_highlights_attributes: %i[id text sort_order _destroy]
>>>>>>> origin/develop
        )
      end

      def build_highlight_rows
<<<<<<< HEAD
        (4 - @experience.experience_highlights.size).times { @experience.experience_highlights.build }
=======
        next_sort_order = (@experience.experience_highlights.map(&:sort_order).max || -1) + 1
        (1 - @experience.experience_highlights.size).times do
          @experience.experience_highlights.build(sort_order: next_sort_order)
          next_sort_order += 1
        end
>>>>>>> origin/develop
      end
    end
  end
end
