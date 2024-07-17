defmodule Rms.Repo.Migrations.CreateTblWagonTrackingDefectSpares do
  use Ecto.Migration

  def change do
    create table(:tbl_wagon_tracking_defect_spares) do
      add :wagon_id, references(:tbl_wagon, on_delete: :nothing)
      add :spare_id, references(:tbl_spares, on_delete: :nothing)
      add :tracker_id, references(:tbl_wagon_tracking, on_delete: :nothing)
      add :quantity, :integer

      timestamps()
    end

    create index(:tbl_wagon_tracking_defect_spares, [:wagon_id])
    create index(:tbl_wagon_tracking_defect_spares, [:spare_id])
    create index(:tbl_wagon_tracking_defect_spares, [:tracker_id])
  end
end
