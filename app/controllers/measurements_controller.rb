class MeasurementsController < ApplicationController
  def index
    @measurement = Current.user.measurements.new(kind: "weight")
    @weights = Current.user.measurements.weight.order(measured_on: :desc)
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
            "weight_form", partial: "measurements/form", locals: { measurement: @measurement }
          )
        end
        format.html do
          @weights = Current.user.measurements.weight.order(measured_on: :desc)
          render :index, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def measurement_params
    params.require(:measurement).permit(:kind, :value, :measured_on)
  end
end
