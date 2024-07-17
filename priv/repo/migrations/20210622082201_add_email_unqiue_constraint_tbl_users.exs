defmodule Rms.Repo.Migrations.AddEmailUnqiueConstraintTblUsers do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_users, [:email], name: :unique_email))
  end

  def down do
    drop(index(:tbl_users, [:email], name: :unique_email))
  end
end
