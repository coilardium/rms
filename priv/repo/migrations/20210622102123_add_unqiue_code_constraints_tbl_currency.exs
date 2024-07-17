defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblCurrency do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_currency, [:code], name: :unique_code))
    create(unique_index(:tbl_currency, [:acronym], name: :unique_acronym))
  end

  def down do
    drop(index(:tbl_currency, [:code], name: :unique_code))
    drop(index(:tbl_currency, [:acronym], name: :unique_acronym))
  end
end
