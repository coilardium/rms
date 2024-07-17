defmodule Rms.Repo.Migrations.RenameCountryToCountryIdInTblRailwayAdministrator do
  use Ecto.Migration

  def up do
    alter table(:tbl_railway_administrator) do
      add :country_id, references(:tbl_country, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_railway_administrator) do
      remove :country_id
    end
  end
end
