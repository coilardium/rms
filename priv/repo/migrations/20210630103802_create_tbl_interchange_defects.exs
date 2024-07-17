defmodule Rms.Repo.Migrations.CreateTblInterchangeDefects do
  use Ecto.Migration

  def change do
    create table(:tbl_interchange_defects) do
      add :spare_id, references(:tbl_spare_fees, on_delete: :nothing)
      add :interchange_id, references(:tbl_interchange, on_delete: :nothing)
      add :wagon_id, references(:tbl_wagon, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_interchange_defects, [:spare_id])
    create index(:tbl_interchange_defects, [:interchange_id])
    create index(:tbl_interchange_defects, [:wagon_id])
  end
end
