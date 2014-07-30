ActiveRecord::Schema.define(:version => 1) do
  create_table :archivals, :force => true do |t|
    t.column :name, :string
    t.column :archival_id, :integer
    t.column :archived, :boolean, default: false
  end

  create_table :exploders, :force => true do |t|
    t.column :archival_id, :integer
    t.column :archived, :boolean, default: false
  end

  if "SQLite" == ActiveRecord::Base.connection.adapter_name
    create_table :archival_kids, :force => true do |t|
      t.column :archival_id, :integer
      t.column :archived, :boolean, default: false
    end

    create_table :archival_grandkids, :force => true do |t|
      t.column :archival_kid_id, :integer
      t.column :archived, :boolean, default: false
    end

    create_table :independent_archivals, :force => true do |t|
      t.column :name, :string
      t.column :archival_id, :integer
      t.column :archived, :boolean, default: false
    end

    create_table :plains, :force => true do |t|
      t.column :name, :string
      t.column :archival_id, :integer
    end

    create_table :mass_attribute_protecteds, :force => true do |t|
      t.column :name, :string
      t.column :archived, :boolean, default: false
    end

    create_table :readonly_when_archiveds, :force => true do |t|
      t.column :name, :string
      t.column :archived, :boolean, default: false
    end

    create_table :missing_archiveds, :force => true do |t|
      t.column :name,   :string
    end

    create_table :polys, :force => true do |t|
      t.references :archiveable, :polymorphic => true
      t.column :archived, :boolean, default: false
    end

    create_table :legacy, :force => true do |t|
      t.column :name, :string
      t.column :archived, :boolean, default: false
    end
  end
end
