defmodule Rms.Repo.Migrations.AddWagonStatusIdWagonConditionIdCurrentStationId do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :current_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :wagon_condition_id, references(:tbl_condition, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :current_station_id
      remove :wagon_condition_id
    end
  end
end
