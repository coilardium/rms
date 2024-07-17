defmodule Rms.Repo.Migrations.ModifyFuelRateFields do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_rates) do
      modify :fuel_rate, :decimal
    end
  end

  def down do
    alter table(:tbl_fuel_rates) do
      modify :fuel_rate, :decimal
    end
  end
end
