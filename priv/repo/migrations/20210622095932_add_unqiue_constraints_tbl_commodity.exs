defmodule Rms.Repo.Migrations.AddUnqiueConstraintsTblCommodity do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_commodity, [:code], name: :unique_code))
    create(unique_index(:tbl_commodity, [:description], name: :unique_description))
  end

  def down do
    drop(index(:tbl_commodity, [:code], name: :unique_code))
    drop(index(:tbl_commodity, [:description], name: :unique_description))
  end
end
