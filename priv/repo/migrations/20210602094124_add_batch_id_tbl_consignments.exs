defmodule Rms.Repo.Migrations.AddBatchIdTblConsignments do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :batch_id, references(:tbl_batch, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :batch_id
    end
  end
end
