defmodule Rms.Repo.Migrations.CreateTblRefuelingType do
  use Ecto.Migration

  def change do
    create table(:tbl_refueling_type) do
      add :code, :string
      add :description, :string
      add :category, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_refueling_type, [:maker_id])
    create index(:tbl_refueling_type, [:checker_id])
  end
end
