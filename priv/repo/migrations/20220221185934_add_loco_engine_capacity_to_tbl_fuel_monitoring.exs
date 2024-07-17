defmodule Rms.Repo.Migrations.AddLocoEngineCapacityToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :loco_engine_capacity, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :loco_engine_capacity
    end
  end
end
