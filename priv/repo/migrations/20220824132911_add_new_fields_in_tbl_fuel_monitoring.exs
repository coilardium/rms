defmodule Rms.Repo.Migrations.AddNewFieldsInTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :driver_name, :string
      add :commercial_clk_name, :string
      add :yard_master_name, :string
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :driver_name, :string
      remove :commercial_clk_name, :string
      remove :yard_master_name, :string
    end
  end
end
