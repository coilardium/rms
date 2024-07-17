defmodule Rms.Repo.Migrations.CreateTblUserRegion do
  use Ecto.Migration

  def change do
    create table(:tbl_user_region) do
      add :description, :string
      add :code, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:tbl_user_region, [:description])
    create unique_index(:tbl_user_region, [:code])
    create index(:tbl_user_region, [:maker_id])
    create index(:tbl_user_region, [:checker_id])
  end
end
