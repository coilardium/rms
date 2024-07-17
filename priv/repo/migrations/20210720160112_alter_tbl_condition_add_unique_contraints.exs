defmodule Rms.Repo.Migrations.AlterTblConditionAddUniqueContraints do
  use Ecto.Migration

  def up do
    create(index(:tbl_condition, [:description], name: :unique_description))
    create(unique_index(:tbl_condition, [:code], name: :unique_code, where: "code is not null"))
  end

  def down do
    drop(index(:tbl_condition, [:description], name: :unique_description))
    drop(unique_index(:tbl_condition, [:code], name: :unique_code))
  end
end
