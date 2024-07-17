defmodule Rms.Repo.Migrations.CreateTblDefectSpares do
  use Ecto.Migration

  def change do
    create table(:tbl_defect_spares) do
      add :spare_id, references(:tbl_spares, on_delete: :nilify_all)
      add :defect_id, references(:tbl_defects, on_delete: :nilify_all)

      timestamps()
    end

    create index(:tbl_defect_spares, [:spare_id])
    create index(:tbl_defect_spares, [:defect_id])
  end
end
