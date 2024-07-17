defmodule Rms.Repo.Migrations.AddBatchIdToTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :batch_id, references(:tbl_batch, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :batch_id
    end
  end
end
