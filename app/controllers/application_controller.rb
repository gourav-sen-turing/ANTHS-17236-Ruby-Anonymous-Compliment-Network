class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Add this to ensure Devise works properly with Turbo
  before_action :store_user_location!, if: :storable_location?

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  # Add this method to handle authentication failures
  def user_not_authenticated
    flash[:alert] = "You need to sign in or sign up before continuing."
    redirect_to new_user_session_path
  end
end
