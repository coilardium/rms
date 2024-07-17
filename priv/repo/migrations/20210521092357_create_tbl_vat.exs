defmodule Rms.Repo.Migrations.CreateTblVat do
  use Ecto.Migration

  def change do
    create table(:tbl_vat) do
      add :rate, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_vat, [:maker_id])
    create index(:tbl_vat, [:checker_id])
  end
end
