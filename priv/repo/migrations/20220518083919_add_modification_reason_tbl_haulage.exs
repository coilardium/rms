defmodule Rms.Repo.Migrations.AddModificationReasonTblHaulage do
  use Ecto.Migration

  def up do
    alter table(:tbl_haulage) do
      add :modification_reason, :string
    end
  end

  def down do
    alter table(:tbl_haulage) do
      remove :modification_reason
    end
  end
end
