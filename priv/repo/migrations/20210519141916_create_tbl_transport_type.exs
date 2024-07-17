defmodule Rms.Repo.Migrations.CreateTblTransportType do
  use Ecto.Migration

  def change do
    create table(:tbl_transport_type) do
      add :code, :string
      add :transport_type, :string
      add :description, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_transport_type, [:maker_id])
    create index(:tbl_transport_type, [:checker_id])
  end
end
