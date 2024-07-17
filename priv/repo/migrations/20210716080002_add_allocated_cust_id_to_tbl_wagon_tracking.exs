defmodule Rms.Repo.Migrations.AddAllocatedCustIdToTblWagonTracking do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_tracking) do
      add :allocated_cust_id, references(:tbl_clients, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_wagon_tracking) do
      remove :allocated_cust_id
    end
  end
end
