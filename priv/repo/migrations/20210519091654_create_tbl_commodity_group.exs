defmodule Rms.Repo.Migrations.CreateTblCommodityGroup do
  use Ecto.Migration

  def change do
    create table(:tbl_commodity_group) do
      add :code, :string
      add :description, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)
      add :commodity_type, :string

      timestamps()
    end

    create index(:tbl_commodity_group, [:maker_id])
    create index(:tbl_commodity_group, [:checker_id])
  end
end
