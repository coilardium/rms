defmodule Rms.Repo.Migrations.AddCurrentWagonTblInterchangeAuxiliary do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_auxiliary) do
      add :current_wagon_id, references(:tbl_wagon, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange_auxiliary) do
      remove :current_wagon_id
    end
  end
end
