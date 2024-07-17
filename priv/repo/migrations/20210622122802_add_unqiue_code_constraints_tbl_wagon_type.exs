defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblWagonType do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_wagon_type, [:code], name: :unique_code))
  end

  def down do
    drop(index(:tbl_wagon_type, [:code], name: :unique_code))
  end
end
