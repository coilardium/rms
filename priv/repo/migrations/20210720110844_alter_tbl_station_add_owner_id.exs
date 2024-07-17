defmodule Rms.Repo.Migrations.AlterTblStationAddOwnerId do
  use Ecto.Migration

  def up do
    alter table(:tbl_stations) do
      add :owner_id, references(:tbl_railway_administrator, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_stations) do
      remove :owner_id
    end
  end
end
