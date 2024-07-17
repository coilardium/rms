defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblSurcharge do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_surcharge, [:code], name: :unique_code))
  end

  def down do
    drop(index(:tbl_surcharge, [:code], name: :unique_code))
  end
end
