defmodule Rms.Repo.Migrations.AddConsignmentIdToTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :consignment_id, references(:tbl_consignments, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :consignment_id
    end
  end
end
