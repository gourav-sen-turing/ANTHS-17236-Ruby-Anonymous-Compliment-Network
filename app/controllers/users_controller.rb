class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]

  def show
    # Load user's received compliments
    @received_compliments = @user.received_compliments
                                .includes(:category, :sender)
                                .order(created_at: :desc)
                                .page(params[:received_page])
                                .per(5)

    # If viewing own profile, also load sent compliments
    if current_user == @user
      @sent_compliments = @user.sent_compliments
                              .where(anonymous: false)  # Only non-anonymous ones
                              .includes(:category, :recipient)
                              .order(created_at: :desc)
                              .page(params[:sent_page])
                              .per(5)
    end

    # Load user's recent mood entries for the chart
    @mood_entries = @user.mood_entries.order(created_at: :desc).limit(14).reverse
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "User not found"
    redirect_to root_path
  end
end
