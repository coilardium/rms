defmodule Rms.Repo.Migrations.AddMeterAtDestToTblMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :meter_at_destin, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :meter_at_destin
    end
  end
end
