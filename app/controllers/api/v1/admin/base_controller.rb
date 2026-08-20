module Api
  module V1
    module Admin
      class BaseController < ApplicationController
        include AdminAuthenticatable
      end
    end
  end
end
