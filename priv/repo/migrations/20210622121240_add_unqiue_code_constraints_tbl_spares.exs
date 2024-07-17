defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblSpares do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_spares, [:code], name: :unique_code))
  end

  def down do
    drop(index(:tbl_spares, [:code], name: :unique_code))
  end
end
