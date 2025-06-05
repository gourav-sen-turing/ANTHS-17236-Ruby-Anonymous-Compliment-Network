class ComplimentsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_compliment, only: [:show, :edit, :update, :destroy]

  def index
    @compliments = Compliment.includes(:category, :recipient)

    # Apply category filter if provided
    if params[:category_id].present?
      @compliments = @compliments.where(category_id: params[:category_id])
    end

    # Apply status filter if admin and filter provided
    if current_user&.admin? && params[:status].present?
      @compliments = @compliments.where(status: params[:status])
    end

    # For regular users, only show compliments they sent or received
    unless current_user&.admin?
      @compliments = @compliments.where(
        "recipient_id = ? OR (sender_id = ? AND anonymous = false)",
        current_user&.id,
        current_user&.id
        )
    end

    # Sort by newest first
    @compliments = @compliments.order(created_at: :desc)

    # Paginate the results
    @compliments = @compliments.page(params[:page]).per(12)
  end

  def show
    # Mark as read if recipient is viewing
    @compliment.mark_as_read! if current_user == @compliment.recipient
  end

  def new
    @compliment = Compliment.new
  end

  # POST /compliments
  def create
    @compliment = current_user.sent_compliments.new(compliment_params)

    respond_to do |format|
      if @compliment.save
        format.html { redirect_to compliments_path, notice: "Compliment was successfully sent!" }
        format.turbo_stream {
          flash.now[:notice] = "Compliment was successfully sent!"
          render turbo_stream: [
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.replace("new_compliment", partial: "compliments/form", locals: { compliment: Compliment.new })
          ]
        }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          flash.now[:alert] = "There was a problem sending your compliment: #{@compliment.errors.full_messages.join(', ')}"
          render turbo_stream: [
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.replace("new_compliment", partial: "compliments/form", locals: { compliment: @compliment })
          ]
        }
      end
    end
  end

  # Supporting AJAX endpoints for dynamic form behavior
  def recipients
    # Find users that are potential recipients (in same communities as current user)
    @recipients = if params[:query].present?
      User.where.not(id: current_user.id)
      .where("name ILIKE ? OR username ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
      .limit(10)
    else
      # Get users from communities the current user belongs to
      community_ids = current_user.communities.pluck(:id)
      User.joins(:memberships)
      .where(memberships: { community_id: community_ids })
      .where.not(id: current_user.id)
      .distinct
      .limit(20)
    end

    respond_to do |format|
      format.json {
        render json: {
          recipients: @recipients.map { |u| { id: u.id, name: u.name, username: u.username } }
        }
      }
    end
  end

  def categories
    # Get relevant categories for the selected recipient
    recipient = User.find_by(id: params[:recipient_id])

    if recipient
      # Find system default categories plus any from communities shared with recipient
      shared_community_ids = current_user.communities.joins(:users)
      .where(users: { id: recipient.id })
      .pluck(:id)

      @categories = Category.where(system_default: true)
      .or(Category.where(community_id: shared_community_ids))
      .distinct
    else
      # Just return system defaults if no recipient selected
      @categories = Category.where(system_default: true)
    end

    respond_to do |format|
      format.json {
        render json: {
          categories: @categories.map { |c| { id: c.id, name: c.name } }
        }
      }
    end
  end

  private

  def set_compliment
    @compliment = Compliment.find(params[:id])
  end

  def compliment_params
    params.require(:compliment).permit(:content, :recipient_id, :category_id, :anonymous, :community_id)
  end

  def build_compliment_from_params
    compliment = current_user.sent_compliments.build(compliment_params)

    # Handle anonymity
    if compliment.anonymous?
      # Generate anonymous token and store hashed IP
      compliment.generate_anonymous_token
      compliment.store_hashed_ip(request.remote_ip) if compliment.anonymous?
    end

    compliment
  end

  def available_categories_for_current_context
    # If we're creating a compliment for a specific community
    if params[:community_id].present?
      community = Community.find_by(id: params[:community_id])
      return [] unless community

      # Return system defaults plus community-specific categories
      Category.where(system_default: true)
      .or(Category.where(community_id: community.id))
      .distinct
    else
      # Just return system defaults for general compliments
      Category.where(system_default: true)
    end
  end
end
