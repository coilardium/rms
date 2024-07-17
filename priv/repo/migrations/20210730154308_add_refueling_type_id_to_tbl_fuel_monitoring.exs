defmodule Rms.Repo.Migrations.AddRefuelingTypeIdToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :refuel_type, references(:tbl_refueling_type, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :refuel_type
    end
  end
end
