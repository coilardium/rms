defmodule Rms.Repo.Migrations.AddStatusToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :status
    end
  end
end
