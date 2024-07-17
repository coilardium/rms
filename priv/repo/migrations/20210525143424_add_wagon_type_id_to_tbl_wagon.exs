defmodule Rms.Repo.Migrations.AddWagonTypeIdToTblWagon do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :wagon_type_id, references(:tbl_wagon_type, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_commodity) do
      remove :wagon_type_id
    end
  end
end
