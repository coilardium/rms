defmodule Rms.Repo.Migrations.CreateTblUserActivity do
  use Ecto.Migration

  def change do
    create table(:tbl_user_activity) do
      add :activity, :string

      timestamps()
    end
  end
end
