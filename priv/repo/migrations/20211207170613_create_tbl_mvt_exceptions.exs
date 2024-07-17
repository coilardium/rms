defmodule Rms.Repo.Migrations.CreateTblMvtExceptions do
  use Ecto.Migration

  def change do
    create table(:tbl_mvt_exceptions) do
      add :capture_date, :date
      add :derailment, :decimal
      add :axles, :decimal
      add :light_engines, :decimal
      add :empty_wagons, :decimal
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_mvt_exceptions, [:maker_id])
    create index(:tbl_mvt_exceptions, [:checker_id])
  end
end
