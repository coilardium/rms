defmodule Rms.Repo.Migrations.CreateTblBatch do
  use Ecto.Migration

  def change do
    create table(:tbl_batch) do
      add :trans_date, :string
      add :batch_no, :string
      add :status, :string
      add :uuid, :string
      add :batch_type, :string
      add :current_user_id, references(:tbl_users, on_delete: :nothing)
      add :last_user_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_batch, [:current_user_id])
    create index(:tbl_batch, [:last_user_id])
  end
end
