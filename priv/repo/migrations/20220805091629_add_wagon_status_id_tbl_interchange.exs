defmodule Rms.Repo.Migrations.AddWagonStatusIdTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      # add :wagon_status_id, references(:tbl_wagon_status, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :wagon_status_id
    end
  end
end
