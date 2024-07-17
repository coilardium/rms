defmodule Rms.Repo.Migrations.ChangeYardMasterToReferenceKey do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :yard_master_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :yard_master_id
    end
  end
end
