class Measurement < ApplicationRecord
  # Value ranges per docs/03-domain.md / E1.2.2, E1.3.2.
  RANGES = { "weight" => 30..300, "waist" => 40..200 }.freeze

  belongs_to :user

  enum :kind, { weight: "weight", waist: "waist" }

  before_validation :default_measured_on

  validates :kind, presence: true
  validates :measured_on, presence: true, uniqueness: { scope: %i[user_id kind] }
  validates :value, presence: true
  validate :value_within_kind_range

  private

  def default_measured_on
    self.measured_on ||= Date.current
  end

  def value_within_kind_range
    range = RANGES[kind]
    return if range.nil? || value.nil?

    errors.add(:value, "вне диапазона для #{kind}") unless range.cover?(value)
  end
end
