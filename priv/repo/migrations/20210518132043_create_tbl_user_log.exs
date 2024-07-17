defmodule Rms.Repo.Migrations.CreateTblUserLog do
  use Ecto.Migration

  def change do
    create table(:tbl_user_log) do
      add :activity, :string
      add :user_id, :integer

      timestamps()
    end
  end
end
