class Report < ApplicationRecord
  belongs_to :reporter, class_name: 'User'
  belongs_to :compliment, counter_cache: :reports_count

  validates :status, inclusion: { in: %w(pending resolved dismissed), allow_nil: true }

  before_validation :set_defaults
  after_create :check_report_threshold

  private

  def set_defaults
    self.status ||= 'pending'
  end

  def check_report_threshold
    # If a compliment gets multiple reports, automatically change its status to pending for review
    if compliment.reports_count >= 3 && compliment.status == 'approved'
      compliment.update(status: 'pending')
    end
  end
end
