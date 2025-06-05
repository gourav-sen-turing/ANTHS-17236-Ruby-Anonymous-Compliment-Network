module Api
  class CategoriesController < ApplicationController
    def index
      if params[:system_only] == 'true'
        @categories = Category.where(system: true).order(:name)
      elsif params[:community_id].present?
        community = Community.find_by(id: params[:community_id])
        if community
          @categories = Category.where(system: true)
                               .or(Category.where(id: community.category_ids))
                               .order(:name)
        else
          @categories = Category.where(system: true).order(:name)
        end
      else
        @categories = Category.order(:name)
      end

      render partial: 'categories/options', locals: { categories: @categories }
    end

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
