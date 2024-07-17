defmodule Rms.Repo.Migrations.AddRegionIdAddDomainIdTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :region_id, references(:tbl_region, column: :id, on_delete: :nothing)
      add :domain_id, references(:tbl_domain, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :region_id
      remove :domain_id
    end
  end
end
