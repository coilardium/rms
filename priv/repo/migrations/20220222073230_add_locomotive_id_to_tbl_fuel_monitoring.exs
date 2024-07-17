defmodule Rms.Repo.Migrations.AddLocomotiveIdToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :locomotive_id, references(:tbl_locomotive, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :locomotive_id
    end
  end
end
