defmodule Rms.Repo.Migrations.ModifyFuelRateInFuelRequisiteTable do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      remove :fuel_rate
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      add :fuel_rate, :decimal, precision: 18, scale: 2
    end
  end
end
