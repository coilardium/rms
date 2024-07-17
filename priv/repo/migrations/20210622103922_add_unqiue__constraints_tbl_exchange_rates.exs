defmodule Rms.Repo.Migrations.AddUnqiueConstraintsTblExchangeRates do
  use Ecto.Migration

  def up do
    flush()

    create unique_index(
             :tbl_exchange_rate,
             [:exchange_rate, :first_currency, :second_currency, :start_date],
             name: :unique_exchange_rate_index
           )
  end

  def down do
    drop index(
           :tbl_exchange_rate,
           [:exchange_rate, :first_currency, :second_currency, :start_date],
           name: :unique_exchange_rate_index
         )

    flush()
  end
end
