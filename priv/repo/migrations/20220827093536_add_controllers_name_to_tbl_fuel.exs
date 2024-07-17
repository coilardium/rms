defmodule Rms.Repo.Migrations.AddControllersNameToTblFuel do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :controllers_name, :string
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :controllers_name, :string
    end
  end
end
