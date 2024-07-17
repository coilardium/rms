defmodule Rms.Repo.Migrations.AddStatusToTblStations do
  use Ecto.Migration

  def up do
    alter table(:tbl_stations) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_stations) do
      remove :status
    end
  end
end
