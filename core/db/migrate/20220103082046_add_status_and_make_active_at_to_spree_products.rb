class AddStatusAndMakeActiveAtToSpreeProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_products, :status, :string, null: false, default: 'draft'
    add_column :spree_products, :make_active_at, :datetime
    add_index :spree_products, :status
    add_index :spree_products, %i[status deleted_at]
    add_index :spree_products, :make_active_at
  end
end
