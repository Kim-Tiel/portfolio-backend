module Web
  module Admin
    class SkillsController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!
      before_action :set_skill, only: %i[show edit update destroy]

      def index
        @skills = Skill.all
      end

      def show; end

      def new
        @skill = Skill.new
      end

      def create
        @skill = Skill.new(skill_params)
        if @skill.save
          redirect_to admin_skill_path(@skill), notice: 'Skill created successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save skill. Please check the form.'
=======
>>>>>>> origin/develop
          render :new
        end
      end

      def edit; end

      def update
        if @skill.update(skill_params)
          redirect_to admin_skill_path(@skill), notice: 'Skill updated successfully.'
        else
<<<<<<< HEAD
          flash.now[:alert] = 'Unable to save skill. Please check the form.'
=======
>>>>>>> origin/develop
          render :edit
        end
      end

      def destroy
        @skill.destroy
        redirect_to admin_skills_path, notice: 'Skill removed successfully.'
      end

      private

      def set_skill
        @skill = Skill.find(params[:id])
      end

      def skill_params
        params.require(:skill).permit(:name, :category, :proficiency, :icon_slug, :sort_order)
      end
    end
  end
end
