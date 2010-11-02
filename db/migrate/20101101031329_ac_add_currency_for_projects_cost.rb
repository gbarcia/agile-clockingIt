class AcAddCurrencyForProjectsCost < ActiveRecord::Migration
  def self.up
     add_column "projects", "currency_iso_code", :string
  end

  def self.down
    remove_column "projects", "currency_iso_code"
  end
end
