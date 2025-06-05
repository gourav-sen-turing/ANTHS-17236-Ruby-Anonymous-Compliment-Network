class ComplimentsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  # IMPORTANT: Explicitly exclude the new action or include only necessary actions
  before_action :set_compliment, only: [:show, :edit, :update, :destroy]

  def index
    @compliments = Compliment.published.order(created_at: :desc).limit(20)
    @compliment = Compliment.new
  end

  # GET /compliments/1
  def show
    # No additional code needed - @compliment is set by the before_action
  end

  # GET /compliments/new
  def new
    # Create a new instance - does NOT need the set_compliment filter
    @compliment = Compliment.new
  end

  # GET /compliments/1/edit
  def edit
    # No additional code needed - @compliment is set by the before_action
  end

  # POST /compliments
  def create
    @compliment = current_user.sent_compliments.new(compliment_params)

    respond_to do |format|
      if @compliment.save
        format.html { redirect_to compliments_path, notice: "Compliment was successfully sent!" }
        format.turbo_stream {
          flash.now[:notice] = "Compliment was successfully sent!"
          # Correct way to implement client-side redirect after Turbo Stream submission
          render turbo_stream: [
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.update("redirect_placeholder",
              template: "shared/turbo_redirect",
              locals: { redirect_url: compliment_path(@compliment) })
          ]
        }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          flash.now[:alert] = "There was a problem sending your compliment."
          render turbo_stream: [
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.replace("new_compliment", partial: "compliments/form", locals: { compliment: @compliment })
          ]
        }
      end
    end
  end

  # PATCH/PUT /compliments/1
  def update
    respond_to do |format|
      if @compliment.update(compliment_params)
        format.html { redirect_to @compliment, notice: "Compliment was successfully updated." }
        format.turbo_stream {
          flash.now[:notice] = "Compliment was successfully updated!"
          render turbo_stream: [
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.replace("compliment_#{@compliment.id}", partial: "compliments/compliment", locals: { compliment: @compliment })
          ]
        }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream {
          flash.now[:alert] = "There was a problem updating the compliment."
          render turbo_stream: [
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.replace("edit_compliment_#{@compliment.id}", partial: "compliments/form", locals: { compliment: @compliment })
          ]
        }
      end
    end
  end

  # DELETE /compliments/1
  def destroy
    @compliment.destroy

    respond_to do |format|
      format.html { redirect_to compliments_url, notice: "Compliment was successfully removed." }
      format.turbo_stream {
        flash.now[:notice] = "Compliment was successfully removed."
        render turbo_stream: [
          turbo_stream.prepend("flash", partial: "shared/flash"),
          turbo_stream.remove("compliment_#{@compliment.id}")
        ]
      }
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
end
