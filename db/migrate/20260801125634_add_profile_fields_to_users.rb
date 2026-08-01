class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :birth_date, :date
    add_column :users, :sex, :string
    add_column :users, :height_cm, :integer
    add_column :users, :activity_factor, :string
  end
end
