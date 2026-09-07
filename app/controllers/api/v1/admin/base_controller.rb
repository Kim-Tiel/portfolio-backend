module Api
  module V1
    module Admin
      class BaseController < ApplicationController
        include AdminAuthenticatable

        private

        # Paginates a scope using the :page / :per_page query params.
        def paginate(scope)
          scope.page(params[:page]).per(params[:per_page])
        end

        # Pagination metadata for a Kaminari-paginated scope, to accompany
        # a `data:` array in an admin index response.
        def pagination_meta(paginated)
          {
            current_page: paginated.current_page,
            total_pages: paginated.total_pages,
            total_count: paginated.total_count,
            per_page: paginated.limit_value
          }
        end
      end
    end
  end
end
