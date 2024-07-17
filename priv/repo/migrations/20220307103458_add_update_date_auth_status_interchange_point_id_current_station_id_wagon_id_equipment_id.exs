defmodule Rms.Repo.Migrations.AddUpdateDateAuthStatusInterchangePointIdCurrentStationIdWagonIdEquipmentId do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_auxiliary) do
      add :update_date, :date
      add :auth_status, :string
      add :interchange_point_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :current_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :wagon_id, references(:tbl_wagon, column: :id, on_delete: :nothing)
      add :equipment_code, :string
    end
  end

  def down do
    alter table(:tbl_interchange_auxiliary) do
      remove :update_date
      remove :auth_status
      remove :interchange_point_id
      remove :current_station_id
      remove :equipment_code
      remove :wagon_id
    end
  end
end
