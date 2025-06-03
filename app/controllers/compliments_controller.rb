class ComplimentsController < ApplicationController
  before_action :authenticate_user!, except: [:create_anonymous]

  # Regular compliment creation (when signed in)
  def create
    @compliment = Compliment.new(compliment_params)
    @compliment.sender = current_user

    # Handle anonymous flag if user wants to remain anonymous
    if params[:compliment][:anonymous].present?
      @compliment.anonymous = true
      @compliment.store_hashed_ip(request.remote_ip)
    end

    if @compliment.save
      redirect_to dashboard_path, notice: "Your compliment has been sent!"
    else
      render :new
    end
  end

  # Special route for completely anonymous compliments (no login required)
  def create_anonymous
    @compliment = Compliment.new(anonymous_compliment_params)
    @compliment.anonymous = true
    @compliment.store_hashed_ip(request.remote_ip)

    # Verify recipient exists
    recipient = User.find_by(id: params[:compliment][:recipient_id])

    if recipient && @compliment.save
      redirect_to root_path, notice: "Your anonymous compliment has been sent!"
    else
      @error_message = "Couldn't send compliment. Please try again."
      render :new_anonymous
    end
  end

  def check_rate_limit
    # If more than 5 anonymous compliments from same IP hash in last hour, reject
    return unless params[:anonymous].present?

    hashed_ip = Digest::SHA256.hexdigest(request.remote_ip + Rails.application.secrets.secret_key_base)
    recent_count = Compliment.where(sender_ip_hash: hashed_ip)
                            .where("created_at > ?", 1.hour.ago)
                            .count

    if recent_count >= 5
      render :rate_limited, status: :too_many_requests
      return false
    end
    true
  end

  private

  def compliment_params
    params.require(:compliment).permit(:content, :recipient_id, :community_id)
  end

  def anonymous_compliment_params
    params.require(:compliment).permit(:content, :recipient_id, :community_id)
  end
end
