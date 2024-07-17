defmodule Rms.Repo.Migrations.AddLocoDriverToTblFuel do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :locomotive_driver_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :locomotive_driver_id
    end
  end
end
