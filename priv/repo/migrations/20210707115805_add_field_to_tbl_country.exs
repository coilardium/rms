defmodule Rms.Repo.Migrations.AddFieldToTblCountry do
  use Ecto.Migration

  def up do
    alter table(:tbl_country) do
      add :region_id, references(:tbl_region, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_country) do
      remove :region_id
    end
  end
end
