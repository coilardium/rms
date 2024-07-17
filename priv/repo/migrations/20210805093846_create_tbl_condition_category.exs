defmodule Rms.Repo.Migrations.CreateTblConditionCategory do
  use Ecto.Migration

  def change do
    create table(:tbl_condition_category) do
      add :code, :string
      add :description, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_condition_category, [:maker_id])
    create index(:tbl_condition_category, [:checker_id])
  end
end
