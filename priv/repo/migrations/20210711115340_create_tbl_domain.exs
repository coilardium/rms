defmodule Rms.Repo.Migrations.CreateTblDomain do
  use Ecto.Migration

  def change do
    create table(:tbl_domain) do
      add :code, :string
      add :description, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_domain, [:maker_id])
    create index(:tbl_domain, [:checker_id])
  end
end
