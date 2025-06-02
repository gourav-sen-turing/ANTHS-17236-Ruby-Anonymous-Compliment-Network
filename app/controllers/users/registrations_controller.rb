class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    # Fix the problematic logic - use respond_to? for safety
    existing_user = User.find_by(email: resource.email)

    # Safely check if the user exists and is unconfirmed
    if existing_user && existing_user.respond_to?(:confirmed?)
      if !existing_user.confirmed?
        existing_user.destroy
      end
    end

    # Change save! to save to prevent exceptions
    resource.save  # removed the ! to prevent raising exceptions
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  def after_sign_up_path_for(resource)
    begin
      dashboard_path # If this exists
    rescue
      root_path # Fallback
    end
  end

  def after_inactive_sign_up_path_for(resource)
    begin
      confirmation_pending_path # If this exists
    rescue
      root_path # Fallback
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :name, :terms_accepted])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :name, :bio, :profile_visible, :anonymity_level, :avatar])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    dashboard_path || root_path
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    confirmation_pending_path || root_path
  end
end
