defmodule Rms.Repo.Migrations.CreateTblUserRole do
  use Ecto.Migration

  def change do
    create table(:tbl_user_role) do
      add :role_desc, :string
      add :role_str, :string
      add :status, :string
      add :maker_id, :integer

      timestamps()
    end
  end
end
