class ProfilesController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(profile_params)
      redirect_to root_path, notice: "Профиль сохранён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:birth_date, :sex, :height_cm, :activity_factor)
  end
end
