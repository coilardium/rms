defmodule Rms.Repo.Migrations.AddDomainIdTblWagonId do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :domain_id, references(:tbl_domain, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :domain_id
    end
  end
end
