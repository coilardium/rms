defmodule Rms.Repo.Migrations.AddStatusMakerIdCheckerIdToTblDefects do
  use Ecto.Migration

  def up do
    alter table(:tbl_defects) do
      add :maker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :checker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_defects) do
      remove :maker_id
      remove :checker_id
      remove :status
    end
  end
end
