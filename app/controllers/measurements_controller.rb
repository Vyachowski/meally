class MeasurementsController < ApplicationController
  def index
    @weight = Current.user.measurements.new(kind: "weight")
    @waist = Current.user.measurements.new(kind: "waist")
    load_collections
  end

  def create
    @measurement = Current.user.measurements.new(measurement_params)

    if @measurement.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to measurements_path, notice: "Замер сохранён" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "#{@measurement.kind}_form", partial: "measurements/form", locals: { measurement: @measurement }
          )
        end
        format.html do
          load_collections
          render :index, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def load_collections
    @weights = Current.user.measurements.weight.order(measured_on: :desc)
    @waists = Current.user.measurements.waist.order(measured_on: :desc)
  end

  def measurement_params
    params.require(:measurement).permit(:kind, :value, :measured_on)
  end
end
