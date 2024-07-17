defmodule Rms.Repo.Migrations.AddNewFieldTblWagonDefect do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_defect) do
      add :defect_ids, :string
    end
  end

  def down do
    alter table(:tbl_wagon_defect) do
      remove :defect_ids
    end
  end
end
