class MoodEntry < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :compliment, optional: true

  # Validations
  validates :value, presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 5
            }
  validates :recorded_at, presence: true
  validate :not_future_dated

  # Constants for mood values
  MOOD_LABELS = {
    1 => "Very Negative",
    2 => "Negative",
    3 => "Neutral",
    4 => "Positive",
    5 => "Very Positive"
  }.freeze

  CONTEXTS = [
    "morning", "afternoon", "evening",
    "work", "personal", "social",
    "family", "health", "finance",
    "other"
  ].freeze

  # Scopes
  scope :recent, -> { order(recorded_at: :desc) }
  scope :in_date_range, ->(start_date, end_date) { where(recorded_at: start_date.beginning_of_day..end_date.end_of_day) }
  scope :by_context, ->(context) { where(context: context) }
  scope :by_value, ->(value) { where(value: value) }
  scope :positive, -> { where(value: 4..5) }
  scope :neutral, -> { where(value: 3) }
  scope :negative, -> { where(value: 1..2) }

  # Callbacks
  before_validation :set_defaults
  after_create :update_user_mood

  # Instance methods
  def mood_label
    MOOD_LABELS[value] || "Unknown"
  end

  def mood_icon
    case value
    when 1 then "😢" # Very Negative
    when 2 then "🙁" # Negative
    when 3 then "😐" # Neutral
    when 4 then "🙂" # Positive
    when 5 then "😄" # Very Positive
    else "❓" # Unknown
    end
  end

  def factors_list
    return [] if factors.blank?
    factors.split(",").map(&:strip)
  end

  def positive?
    value >= 4
  end

  def negative?
    value <= 2
  end

  def neutral?
    value == 3
  end

  # Analytics methods
  def self.daily_average(date = Date.current)
    where(recorded_at: date.all_day).average(:value)&.round(2) || 0
  end

  def self.weekly_average(date = Date.current)
    start_date = date.beginning_of_week
    end_date = date.end_of_week
    where(recorded_at: start_date.beginning_of_day..end_date.end_of_day)
      .average(:value)&.round(2) || 0
  end

  def self.monthly_average(date = Date.current)
    start_date = date.beginning_of_month
    end_date = date.end_of_month
    where(recorded_at: start_date.beginning_of_day..end_date.end_of_day)
      .average(:value)&.round(2) || 0
  end

  def self.trend_data(user, range = 30)
    end_date = Date.current
    start_date = end_date - range.days

    # Group by date and calculate averages
    user.mood_entries
        .where(recorded_at: start_date.beginning_of_day..end_date.end_of_day)
        .group_by { |entry| entry.recorded_at.to_date }
        .transform_values { |entries| entries.sum { |e| e.value } / entries.size.to_f }
  end

  # Calculate mood change after compliment
  def self.compliment_impact(compliment, window_hours = 24)
    return nil unless compliment.recipient

    # Find mood entries before the compliment
    before_entries = compliment.recipient.mood_entries
                             .where(recorded_at: (compliment.created_at - window_hours.hours)..compliment.created_at)

    # Find mood entries after the compliment
    after_entries = compliment.recipient.mood_entries
                            .where(recorded_at: compliment.created_at..(compliment.created_at + window_hours.hours))

    # Calculate average mood before and after
    before_avg = before_entries.average(:value)&.round(2) || nil
    after_avg = after_entries.average(:value)&.round(2) || nil

    return nil if before_avg.nil? || after_avg.nil?

    {
      before_average: before_avg,
      after_average: after_avg,
      change: (after_avg - before_avg).round(2),
      improvement: after_avg > before_avg,
      entries_before: before_entries.count,
      entries_after: after_entries.count
    }
  end

  private

  def set_defaults
    self.recorded_at ||= Time.current
  end

  def update_user_mood
    # Update the user's current mood
    user.update(
      current_mood: value,
      mood_updated_at: recorded_at
    ) if user.respond_to?(:current_mood) && user.respond_to?(:mood_updated_at)
  end

  def not_future_dated
    return unless recorded_at

    if recorded_at > Time.current
      errors.add(:recorded_at, "cannot be in the future")
    end
  end
end
