defmodule Rms.Repo.Migrations.AlterTblWagonStatusModifyUniqueContraint do
  use Ecto.Migration

  def up do
    # create(index(:tbl_status, [:status], name: :unique_status))
    # create(unique_index(:tbl_status, [:code], name: :unique_code, where: "code is not null"))
  end

  def down do
    # drop(index(:tbl_status, [:status], name: :unique_status))
    # drop(unique_index(:tbl_status, [:code], name: :unique_code))
  end
end
