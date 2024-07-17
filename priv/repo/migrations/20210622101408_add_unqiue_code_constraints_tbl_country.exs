defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblCountry do
  use Ecto.Migration

  def up do
    # create(unique_index(:tbl_country, [:code], name: :unique_code))
  end

  def down do
    # drop(index(:tbl_country, [:code], name: :unique_code))
  end
end
