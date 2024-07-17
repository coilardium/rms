defmodule Rms.Repo.Migrations.AddUniqueConstrantTblLocoDriver do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_loco_driver, [:user_id], name: :unique_loco_driver))
  end

  def down do
    drop(index(:tbl_loco_driver, [:user_id], name: :unique_loco_driver))
  end
end
