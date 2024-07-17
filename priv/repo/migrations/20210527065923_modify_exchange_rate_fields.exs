defmodule Rms.Repo.Migrations.ModifyExchangeRateFields do
  use Ecto.Migration

  def up do
    alter table(:tbl_exchange_rate) do
      modify :first_currency, :decimal
      modify :second_currency, :decimal
      modify :exchange_rate, :decimal
    end
  end

  def down do
    alter table(:tbl_exchange_rate) do
      modify :first_currency, :decimal
      modify :second_currency, :decimal
      modify :exchange_rate, :decimal
    end
  end
end
