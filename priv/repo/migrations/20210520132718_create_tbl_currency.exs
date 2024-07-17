defmodule Rms.Repo.Migrations.CreateTblCurrency do
  use Ecto.Migration

  def change do
    create table(:tbl_currency) do
      add :code, :string
      add :acronym, :string
      add :description, :string
      add :symbol, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_currency, [:maker_id])
    create index(:tbl_currency, [:checker_id])
  end
end
