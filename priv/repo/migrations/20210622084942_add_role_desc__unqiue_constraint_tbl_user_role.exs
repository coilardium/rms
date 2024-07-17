defmodule Rms.Repo.Migrations.AddRoleDescUnqiueConstraintTblUserRole do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_user_role, [:role_desc], name: :unique_role_desc))
  end

  def down do
    drop(index(:tbl_user_role, [:role_desc], name: :unique_role_desc))
  end
end
