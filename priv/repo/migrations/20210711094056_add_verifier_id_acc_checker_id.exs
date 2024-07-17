defmodule Rms.Repo.Migrations.AddVerifierIdAccCheckerId do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :verifier_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :acc_checker_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :verifier_id
      remove :acc_checker_id
    end
  end
end
