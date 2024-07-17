defmodule Rms.Repo.Migrations.CreateTblStatus do
  use Ecto.Migration

  def change do
    create table(:tbl_status) do
      add :code, :string
      add :rec_status, :string
      add :description, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_status, [:maker_id])
    create index(:tbl_status, [:checker_id])
  end
end
