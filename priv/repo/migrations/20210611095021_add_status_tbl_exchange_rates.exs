defmodule Rms.Repo.Migrations.AddStatusTblExchangeRates do
  use Ecto.Migration

  def up do
    alter table(:tbl_exchange_rate) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_exchange_rate) do
      remove :status
    end
  end
end
