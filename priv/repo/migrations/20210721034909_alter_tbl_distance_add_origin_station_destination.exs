defmodule Rms.Repo.Migrations.AlterTblDistanceAddOriginStationDestination do
  use Ecto.Migration

  def up do
    alter table(:tbl_distance) do
      remove :destin
      remove :station_orig
      add :destin, references(:tbl_stations, column: :id, on_delete: :nothing)
      add :station_orig, references(:tbl_stations, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_distance) do
      remove :destin
      remove :station_orig
      add :destin, :string
      add :station_orig, :string
    end
  end
end
