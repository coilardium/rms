defmodule Rms.Repo.Migrations.AddNewFieldsToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :oil_rep_name, :string
      add :asset_protection_officers_name, :string
      add :other_refuel, :string
      add :other_refuel_no, :string
      add :stn_foreman, :string
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :oil_rep_name, :string
      remove :asset_protection_officers_name, :string
      remove :other_refuel, :string
      remove :other_refuel_no, :string
      remove :stn_foreman, :string
    end
  end
end
