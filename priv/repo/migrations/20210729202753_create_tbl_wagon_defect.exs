defmodule Rms.Repo.Migrations.CreateTblWagonDefect do
  use Ecto.Migration

  def change do
    create table(:tbl_wagon_defect) do
      add :wagon_id, references(:tbl_wagon, on_delete: :nothing)
      add :tracker_id, references(:tbl_wagon_tracking, on_delete: :nothing)
      add :defect_id, references(:tbl_defects, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_wagon_defect, [:wagon_id])
    create index(:tbl_wagon_defect, [:tracker_id])
    create index(:tbl_wagon_defect, [:defect_id])
    create index(:tbl_wagon_defect, [:maker_id])
    create index(:tbl_wagon_defect, [:checker_id])
  end
end
