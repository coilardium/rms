defmodule Rms.Repo.Migrations.AddNewFieldToFuelMonitoringShunt do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :shunt, :string
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :shunt
    end
  end
end
