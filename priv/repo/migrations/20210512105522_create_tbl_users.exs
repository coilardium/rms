defmodule Rms.Repo.Migrations.CreateTblUsers do
  use Ecto.Migration

  def change do
    create table(:tbl_users) do
      add :first_name, :string
      add :last_name, :string
      add :mobile, :string
      add :email, :string
      add :username, :string
      add :password, :string
      add :user_role, :integer
      add :user_id, :string
      add :status, :string

      timestamps()
    end
  end
end
