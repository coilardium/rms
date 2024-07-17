defmodule Rms.Repo.Migrations.AddMobileUnqiueConstraintTblUsers do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_users, [:mobile], name: :unique_mobile))
  end

  def down do
    drop(index(:tbl_users, [:mobile], name: :unique_mobile))
  end
end
