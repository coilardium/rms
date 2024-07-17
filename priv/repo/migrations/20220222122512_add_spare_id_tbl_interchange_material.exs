defmodule Rms.Repo.Migrations.AddSpareIdTblInterchangeMaterial do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_material) do
      add :spare_id, references(:tbl_spares, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange_material) do
      remove :spare_id
    end
  end
end
