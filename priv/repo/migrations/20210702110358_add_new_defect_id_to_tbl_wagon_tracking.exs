defmodule Rms.Repo.Migrations.AddNewDefectIdToTblWagonTracking do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_tracking) do
      add :defect_id, references(:tbl_defects, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_wagon_tracking) do
      remove :defect_id
    end
  end
end
