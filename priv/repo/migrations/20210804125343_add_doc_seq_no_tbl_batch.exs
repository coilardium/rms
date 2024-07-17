defmodule Rms.Repo.Migrations.AddDocSeqNoTblBatch do
  use Ecto.Migration

  def up do
    alter table(:tbl_batch) do
      add :doc_seq_no, :string
    end
  end

  def down do
    alter table(:tbl_batch) do
      remove :doc_seq_no
    end
  end
end
