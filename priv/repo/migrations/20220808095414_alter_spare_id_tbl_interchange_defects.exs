defmodule Rms.Repo.Migrations.AlterSpareIdTblInterchangeDefects do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_defects) do
      add :defect_spare_id, references(:tbl_spares, column: :id, on_delete: :nothing)
    end
  end

  def down do
    remove :defect_spare_id
  end


end
