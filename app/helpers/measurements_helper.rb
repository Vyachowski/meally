module MeasurementsHelper
  LABELS = { "weight" => "Вес, кг", "waist" => "Талия, см" }.freeze
  UNITS = { "weight" => "кг", "waist" => "см" }.freeze

  def measurement_label(kind)
    LABELS.fetch(kind)
  end

  def measurement_unit(kind)
    UNITS.fetch(kind)
  end
end
