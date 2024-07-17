defmodule Rms.Repo.Migrations.AddMakerIdAndCheckerId do
  use Ecto.Migration

  def up do
    alter table(:tbl_email_alerts) do
      add :maker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :checker_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_email_alerts) do
      remove :maker_id
      remove :checker_id
    end
  end
end
