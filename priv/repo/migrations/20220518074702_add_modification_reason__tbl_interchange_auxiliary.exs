defmodule Rms.Repo.Migrations.AddModificationReasonTblInterchangeAuxiliary do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_auxiliary) do
      add :modification_reason, :string
    end
  end

  def down do
    alter table(:tbl_interchange_auxiliary) do
      remove :modification_reason
    end
  end
end
