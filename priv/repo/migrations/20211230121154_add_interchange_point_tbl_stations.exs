defmodule Rms.Repo.Migrations.AddInterchangePointTblStations do
  use Ecto.Migration

  def up do
    alter table(:tbl_stations) do
      add :interchange_point, :string
    end
  end

  def down do
    alter table(:tbl_stations) do
      remove :interchange_point
    end
  end
end
