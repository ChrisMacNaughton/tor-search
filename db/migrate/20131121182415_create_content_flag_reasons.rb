class CreateContentFlagReasons < ActiveRecord::Migration
  def up
    create_table :flag_reasons do |t|
      t.text :name
      t.text :description

      t.timestamps
    end
    execute("INSERT INTO flag_reasons (name, description, created_at, updated_at) VALUES ('Child Pornography','Child pornography is a violation of our policies', NOW(), NOW())")
  end

  def down
    drop_table :flag_reasons
  end
end
