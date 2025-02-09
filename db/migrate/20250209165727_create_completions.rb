class CreateCompletions < ActiveRecord::Migration[8.0]
  def change
    create_table :completions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.text :prompt, null: false, default: ""
      t.text :response, null: false, default: ""
      t.text :model, null: false, default: ""

      t.timestamps
    end
  end
end
