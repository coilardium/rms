defmodule Rms.Repo.Migrations.CreateTblLocomotiveModels do
  use Ecto.Migration

  def change do
    create table(:tbl_locomotive_models) do
      add :model, :string
      add :self_weight, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_locomotive_models, [:maker_id])
    create index(:tbl_locomotive_models, [:checker_id])
  end
end
