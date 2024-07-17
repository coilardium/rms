defmodule Rms.Repo.Migrations.CreateTblCondition do
  use Ecto.Migration

  def change do
    create table(:tbl_condition) do
      add :code, :string
      add :con_status, :string
      add :description, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_condition, [:maker_id])
    create index(:tbl_condition, [:checker_id])
  end
end
