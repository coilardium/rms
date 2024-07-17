defmodule Rms.Repo.Migrations.AddRegionIdTblStations do
  use Ecto.Migration

  def up do
    alter table(:tbl_stations) do
      add :region_id, references(:tbl_region, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_stations) do
      remove :region_id
    end
  end
end
