defmodule Rms.Repo.Migrations.AddStatusTblInterchangeDefects do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_defects) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_interchange_defects) do
      remove :status
    end
  end
end
