class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # GET /resource/sign_up
  def new
    build_resource({})
    yield resource if block_given?
    respond_with resource
  end

  # POST /resource
  def create
    super do |resource|
      # You can add custom logic here after user creation attempt
      # For example, storing original domain from email
      if resource.persisted? && resource.email.present?
        resource.email_domain = resource.email.split('@').last
        resource.save
      end
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end

  # The path used after sign up
  def after_sign_up_path_for(resource)
    # Redirect to custom path after signup
    dashboard_path
  end
end
