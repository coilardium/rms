defmodule Rms.Repo.Migrations.AddUniqueConstraintDateToTblFuelRates do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_fuel_rates, [:month, :station_id], name: :unique_date)
  end

  def down do
    drop index(:tbl_fuel_rates, [:month, :station_id], name: :unique_date)
  end
end
