defmodule Rms.Repo.Migrations.AddDefectIdTblDefects do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_defects) do
      add :defect_id, references(:tbl_defects, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange_defects) do
      remove :defect_id
    end
  end
end
