defmodule Rms.Repo.Migrations.AddUserRegionIdToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :user_region_id, references(:tbl_user_region, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :user_region_id
    end
  end
end
