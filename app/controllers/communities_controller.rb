class CommunitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community, only: [:show, :edit, :update, :destroy, :join, :leave]

  def index
    @communities = Community.public_or_restricted.order(created_at: :desc)
    @user_communities = current_user.joined_communities if user_signed_in?
  end

  def new
    @community = Community.new
  end

  def create
    @community = current_user.created_communities.new(community_params)

    if @community.save
      # Automatically join the creator as an admin with active status
      current_user.memberships.create(
        community: @community,
        role: :admin,
        status: :active,
        joined_at: Time.current
        )

      redirect_to @community, notice: "Community created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @members = @community.users.includes(:memberships)
    @compliments = @community.compliments.recent.limit(10)
  end

  def join
    membership = current_user.memberships.find_or_initialize_by(community: @community)

    # Auto-approve if it's a public community
    status = @community.public? ? :active : :pending

    if membership.new_record?
      membership.status = status
      membership.save
      notice = status == :active ? "You've joined the community!" : "Request to join has been submitted."
      redirect_to @community, notice: notice
    else
      redirect_to @community, alert: "You already have a relationship with this community."
    end
  end

  def leave
    membership = current_user.memberships.find_by(community: @community)

    if membership&.destroy
      redirect_to communities_path, notice: "You've left the community."
    else
      redirect_to @community, alert: "Error leaving the community."
    end
  end

  private

  def set_community
    @community = Community.find_by(slug: params[:id])
  end

  def community_params
    params.require(:community).permit(:name, :description, :community_type, :domain, :privacy_level)
  end
end
