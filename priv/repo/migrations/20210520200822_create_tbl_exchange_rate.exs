defmodule Rms.Repo.Migrations.CreateTblExchangeRate do
  use Ecto.Migration

  def change do
    create table(:tbl_exchange_rate) do
      add :symbol, :string
      add :first_currency, :decimal
      add :second_currency, :decimal
      add :start_date, :string
      add :exchange_rate, :decimal
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_exchange_rate, [:maker_id])
    create index(:tbl_exchange_rate, [:checker_id])
  end
end
