module Web
  module Admin
    class EducationsController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!
      before_action :set_education, only: %i[show edit update destroy]

      def index
        @educations = Education.all
      end

      def show; end

      def new
        @education = Education.new
        build_milestone_rows
      end

      def create
        @education = Education.new(education_params)
        if @education.save
          redirect_to admin_education_path(@education), notice: 'Education created successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save education. Please check the form.'
=======
>>>>>>> origin/develop
          build_milestone_rows
          render :new
        end
      end

      def edit
        build_milestone_rows
      end

      def update
        if @education.update(education_params)
          redirect_to admin_education_path(@education), notice: 'Education updated successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save education. Please check the form.'
=======
>>>>>>> origin/develop
          build_milestone_rows
          render :edit
        end
      end

      def destroy
        @education.destroy
        redirect_to admin_educations_path, notice: 'Education removed successfully.'
      end

      private

      def set_education
        @education = Education.find(params[:id])
      end

      def education_params
<<<<<<< HEAD
        params.require(:education).permit(:institution, :degree, :location, :sort_order,
=======
        params.require(:education).permit(:institution, :degree, :location, :sort_order, :field, :start_date, :end_date, :is_graduated,
>>>>>>> origin/develop
                                          education_milestones_attributes: %i[id occurred_on description _destroy])
      end

      def build_milestone_rows
        (1 - @education.education_milestones.size).times { @education.education_milestones.build }
      end
    end
  end
end
