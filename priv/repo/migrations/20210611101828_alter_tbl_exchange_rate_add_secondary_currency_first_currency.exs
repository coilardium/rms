defmodule Rms.Repo.Migrations.AlterTblExchangeRateAddSecondaryCurrencyFirstCurrency do
  use Ecto.Migration

  def up do
    alter table(:tbl_exchange_rate) do
      remove :first_currency
      remove :second_currency
      add :first_currency, references(:tbl_currency, column: :id, on_delete: :nothing)
      add :second_currency, references(:tbl_currency, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_exchange_rate) do
      remove :first_currency
      remove :second_currency
      add :first_currency, :decimal, precision: 18, scale: 2
      add :second_currency, :decimal, precision: 18, scale: 2
    end
  end
end
