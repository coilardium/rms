defmodule Rms.Repo.Migrations.AddStationIdTblWagon do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :wagon_status_id, references(:tbl_wagon_status, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :wagon_status_id
    end
  end
end
