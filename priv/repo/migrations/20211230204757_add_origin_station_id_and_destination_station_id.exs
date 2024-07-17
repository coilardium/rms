defmodule Rms.Repo.Migrations.AddOriginStationIdAndDestinationStationId do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :origin_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :destination_station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :origin_station_id
      remove :destination_station_id
    end
  end
end
