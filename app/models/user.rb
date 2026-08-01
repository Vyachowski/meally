class User < ApplicationRecord
  SEXES = %w[male female].freeze
  ACTIVITY_FACTORS = %w[1.2 1.375 1.55 1.725].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Profile fields are optional until the user fills them in (E1.1).
  validates :sex, inclusion: { in: SEXES }, allow_nil: true
  validates :activity_factor, inclusion: { in: ACTIVITY_FACTORS }, allow_nil: true
  validates :height_cm, numericality: { in: 120..250 }, allow_nil: true
  validate :age_within_range

  def age(on = Date.current)
    return unless birth_date

    years = on.year - birth_date.year
    years -= 1 if on < birth_date + years.years
    years
  end

  private

  def age_within_range
    return if birth_date.nil?

    errors.add(:birth_date, "must correspond to age 14–100") unless age&.between?(14, 100)
  end
end
