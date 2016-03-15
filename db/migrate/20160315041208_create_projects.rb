class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :project_id, null: false, default: '11'
      t.string :create_date,  null: false, default: '11'
      t.string :title,  null: false, default: '11'
      t.text :short_body,  null: false, default: '11'
      t.string :link,  null: false, default: '11'
      t.string :price,  null: false, default: '11'

      t.timestamps null: false
    end
  end
end
