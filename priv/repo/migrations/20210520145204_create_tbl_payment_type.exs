defmodule Rms.Repo.Migrations.CreateTblPaymentType do
  use Ecto.Migration

  def change do
    create table(:tbl_payment_type) do
      add :code, :string
      add :status, :string
      add :description, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_payment_type, [:maker_id])
    create index(:tbl_payment_type, [:checker_id])
  end
end
