defmodule Rms.Repo.Migrations.CreateTblSpareFees do
  use Ecto.Migration

  def change do
    create table(:tbl_spare_fees) do
      add :code, :string
      add :amount, :decimal, precision: 18, scale: 2
      add :start_date, :date
      add :spare_id, references(:tbl_spares, on_delete: :nothing)
      add :currency_id, references(:tbl_currency, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_spare_fees, [:spare_id])
    create index(:tbl_spare_fees, [:currency_id])
  end
end
