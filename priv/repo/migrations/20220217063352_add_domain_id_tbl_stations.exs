defmodule Rms.Repo.Migrations.AddDomainIdTblStations do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_fees) do
      add :wagon_type_id, references(:tbl_wagon_type, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange_fees) do
      remove :wagon_type_id
    end
  end
end
