defmodule Rms.Repo.Migrations.AddCustomerIdToTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :customer_id, references(:tbl_clients, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :customer_id
    end
  end
end
