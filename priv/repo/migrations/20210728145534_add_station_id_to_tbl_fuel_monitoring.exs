defmodule Rms.Repo.Migrations.AddStationIdToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :depo_stn_rate, references(:tbl_stations, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :depo_stn_rate
    end
  end
end
