class CreateMeasurements < ActiveRecord::Migration[8.1]
  def change
    create_table :measurements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.decimal :value, precision: 5, scale: 1, null: false
      t.date :measured_on, null: false

      t.timestamps
    end

    add_index :measurements, %i[user_id kind measured_on], unique: true
  end
end
