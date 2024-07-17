defmodule Rms.Repo.Migrations.CreateTblSection do
  use Ecto.Migration

  def change do
    create table(:tbl_section) do
      add :code, :string
      add :description, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_section, [:maker_id])
    create index(:tbl_section, [:checker_id])
  end
end
