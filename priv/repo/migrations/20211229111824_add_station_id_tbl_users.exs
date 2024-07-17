defmodule Rms.Repo.Migrations.AddStationIdTblUsers do
  use Ecto.Migration

  def up do
    alter table(:tbl_users) do
      add :station_id, references(:tbl_stations, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_users) do
      remove :station_id
    end
  end
end