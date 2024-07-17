defmodule Rms.Repo.Migrations.AddDepoStnToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :depo_stn, references(:tbl_stations, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :depo_stn
    end
  end
end
