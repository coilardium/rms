defmodule Rms.Repo.Migrations.AddDomainIdToTblWagonTracker do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_tracking) do
      add :domain_id, references(:tbl_domain, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_wagon_tracking) do
      remove :domain_id
    end
  end
end
