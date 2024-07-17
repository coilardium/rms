defmodule Rms.Repo.Migrations.CreateTblInterchangeFees do
  use Ecto.Migration

  def change do
    create table(:tbl_interchange_fees) do
      add :amount, :decimal, precision: 18, scale: 2
      add :year, :string
      add :currency_id, references(:tbl_currency, on_delete: :nothing)
      add :partner_id, references(:tbl_railway_administrator, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_interchange_fees, [:currency_id])
    create index(:tbl_interchange_fees, [:partner_id])
  end
end
