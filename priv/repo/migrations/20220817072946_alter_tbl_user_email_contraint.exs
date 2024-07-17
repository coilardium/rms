defmodule Rms.Repo.Migrations.AlterTblUserEmailContraint do
  use Ecto.Migration

  def up do
    drop(index(:tbl_users, [:email], name: :unique_email))
    create(unique_index(:tbl_users, [:email], name: :unique_email, where: "email is not null"))
  end

  def down do
    drop(unique_index(:tbl_users, [:email], name: :unique_email, where: "email is not null"))
    create(index(:tbl_users, [:email], name: :unique_email))
  end
end
