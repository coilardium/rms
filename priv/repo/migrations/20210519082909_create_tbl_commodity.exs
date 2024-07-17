defmodule Rms.Repo.Migrations.CreateTblCommodity do
  use Ecto.Migration

  def change do
    create table(:tbl_commodity) do
      add :code, :string
      add :description, :string
      add :commodity_group, :string
      add :is_container, :string
      add :com_group_id, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_commodity, [:maker_id])
    create index(:tbl_commodity, [:checker_id])
  end
end
