defmodule Rms.Repo.Migrations.AddStationCodeTblStation do
  use Ecto.Migration

  def up do
    alter table(:tbl_stations) do
      add :station_code, :string
    end
  end

  def down do
    alter table(:tbl_stations) do
      remove :station_code
    end
  end
end
