defmodule Rms.Repo.Migrations.AddAllocatedCustAndAssigned do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :allocated_cust_id, references(:tbl_clients, column: :id, on_delete: :nothing)
      add :assigned, :string
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :allocated_cust_id
      remove :assigned
    end
  end
end
