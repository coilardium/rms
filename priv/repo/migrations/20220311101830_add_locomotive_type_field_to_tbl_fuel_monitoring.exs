defmodule Rms.Repo.Migrations.AddLocomotiveTypeFieldToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :locomotive_type, :string
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :locomotive_type
    end
  end
end
