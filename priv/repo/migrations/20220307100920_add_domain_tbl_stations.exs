defmodule Rms.Repo.Migrations.AddDomainTblStations do
  use Ecto.Migration

  def up do
    alter table(:tbl_stations) do
      # references(:tbl_domain, column: :id)
      add_if_not_exists(:domain_id, :id)
    end

    flush()

    execute """
    ALTER TABLE tbl_stations
      ADD FOREIGN KEY (domain_id) REFERENCES tbl_domain(id);
    """
  end

  def down do
    alter table(:tbl_stations) do
      remove_if_exists(:domain_id, references(:tbl_domain, column: :id))
    end
  end
end
