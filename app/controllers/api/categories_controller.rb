module Api
  class CategoriesController < ApplicationController
    def templates
      @category = Category.find(params[:id])

      begin
        templates = @category.template_suggestions.present? ?
                    JSON.parse(@category.template_suggestions) :
                    []

        render json: { templates: templates }
      rescue JSON::ParserError
        render json: { templates: [], error: "Invalid template format" }
      end
    end
  end
end
