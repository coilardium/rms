defmodule Rms.Repo.Migrations.AddNewFieldFueRates do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_rates) do
      modify :fuel_rate, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_fuel_rates) do
      remove :fuel_rate
    end
  end
end
