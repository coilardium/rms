defmodule Rms.Repo.Migrations.AddUserStationIdTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :user_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :user_station_id
    end
  end
end
