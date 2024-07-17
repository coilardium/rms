defmodule Rms.Repo.Migrations.CreateTblTrainType do
  use Ecto.Migration

  def change do
    create table(:tbl_train_type) do
      add :code, :string
      add :description, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_train_type, [:maker_id])
    create index(:tbl_train_type, [:checker_id])
  end
end
