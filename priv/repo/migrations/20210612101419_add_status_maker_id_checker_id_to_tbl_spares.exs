defmodule Rms.Repo.Migrations.AddStatusMakerIdCheckerIdToTblSpares do
  use Ecto.Migration

  def up do
    alter table(:tbl_spares) do
      add :maker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :checker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_spares) do
      remove :maker_id
      remove :checker_id
      remove :status
    end
  end
end
