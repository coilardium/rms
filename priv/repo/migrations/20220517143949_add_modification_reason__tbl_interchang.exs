defmodule Rms.Repo.Migrations.AddModificationReasonTblInterchang do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :modification_reason, :string
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :modification_reason
    end
  end
end
