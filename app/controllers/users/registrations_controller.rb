class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    byebug
    build_resource(sign_up_params)

    # Fix for NameError - Use safer navigation operator and check if user exists and is not confirmed
    existing_user = User.find_by(email: resource.email)
    if existing_user && !existing_user.confirmed?
      existing_user.destroy
    end

    # Continue with the standard Devise flow
    resource.save!
    yield resource if block_given?
    # ...rest of the method remains the same
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
