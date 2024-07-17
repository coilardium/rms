defmodule Rms.Repo.Migrations.AlterTblConditionAddUniqueDescriptionContraint do
  use Ecto.Migration

  def up do
    create_if_not_exists(index(:tbl_condition, [:description], name: :unique_description))
  end

  def down do
    drop_if_exists(index(:tbl_condition, [:description], name: :unique_description))
  end
end
