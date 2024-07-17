defmodule Rms.Repo.Migrations.CreateTblLocoDriver do
  use Ecto.Migration

  def change do
    create table(:tbl_loco_driver) do
      add :status, :string
      add :user_id, :integer
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_loco_driver, [:maker_id])
    create index(:tbl_loco_driver, [:checker_id])
  end
end
