defmodule Rms.Repo.Migrations.DropUniqueConstraintFromTblUsers do
  use Ecto.Migration

  def up do
    drop_if_exists(index(:tbl_users, [:mobile], name: :unique_mobile))
  end

  def down do
    create_if_not_exists(unique_index(:tbl_users, [:mobile], name: :unique_mobile))
  end
end
