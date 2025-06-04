class AuditLog < ApplicationRecord
  belongs_to :user
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true
end
