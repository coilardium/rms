defmodule Rms.Repo.Migrations.ModifyFuelRateFieldToDecimal do
  use Ecto.Migration

  def up do
    # alter table(:tbl_fuel_rates) do
    #   # modify :fuel_rate, :decimal, :decimal, precision: 18, scale: 2
    #   remove :fuel_rate
    # end
  end

  def down do
    # alter table(:tbl_fuel_rates) do
    #   add :loco_engine_capacity, :decimal, precision: 18, scale: 2
    # end
  end
end
