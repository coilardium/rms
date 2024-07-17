defmodule Rms.Repo.Migrations.CreateTblStations do
  use Ecto.Migration

  def change do
    create table(:tbl_stations) do
      add :acronym, :string
      add :description, :string
      add :station_id, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_stations, [:maker_id])
    create index(:tbl_stations, [:checker_id])
  end
end
