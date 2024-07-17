defmodule Rms.Repo.Migrations.AddUniqueCurrencyConstriant do
  use Ecto.Migration

  def up do
    create_if_not_exists unique_index(:tbl_currency, [:type],
                           name: :unique_local_currency,
                           where: "type = 'LOCAL'"
                         )
  end

  def down do
    drop_if_exists index(:tbl_currency, [:type],
                     name: :unique_local_currency,
                     where: "type = 'LOCAL'"
                   )
  end
end
