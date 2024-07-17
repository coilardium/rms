defmodule Rms.Repo.Migrations.AddWagonSubTypeIdTblWagon do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :wagon_sub_type_id, references(:tbl_wagon_type, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :wagon_sub_type_id
    end
  end
end
