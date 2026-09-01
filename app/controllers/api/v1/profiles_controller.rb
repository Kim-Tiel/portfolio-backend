module Api
  module V1
    class ProfilesController < ApplicationController
      def show
        render json: ProfileSerializer.new(Profile.instance).as_json
      end
    end
  end
end
