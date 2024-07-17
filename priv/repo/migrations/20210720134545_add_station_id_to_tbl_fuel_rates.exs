defmodule Rms.Repo.Migrations.AddStationIdToTblFuelRates do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_rates) do
      add :station_id, references(:tbl_stations, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_fuel_rates) do
      remove :station_id
    end
  end
end
