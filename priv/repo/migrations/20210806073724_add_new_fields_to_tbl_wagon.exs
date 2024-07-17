defmodule Rms.Repo.Migrations.AddNewFieldsToTblWagon do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :station_id, references(:tbl_stations, column: :id, on_delete: :nilify_all)
      add :condition_id, references(:tbl_condition, column: :id, on_delete: :nilify_all)
      add :load_status, :string
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :station_id
      remove :condition_id
      remove :load_status
    end
  end
end
