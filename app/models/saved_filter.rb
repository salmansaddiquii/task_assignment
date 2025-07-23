class SavedFilter < ApplicationRecord
  belongs_to :user, optional: true
  validates :filterable_type, presence: true
  validates :parameters, presence: true

  def symbolized_parameters
    parameters.deep_symbolize_keys
  end
end
