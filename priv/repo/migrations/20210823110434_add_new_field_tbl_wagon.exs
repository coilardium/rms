defmodule Rms.Repo.Migrations.AddNewFieldTblWagon do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :mvt_status, :string
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :mvt_status
    end
  end
end
