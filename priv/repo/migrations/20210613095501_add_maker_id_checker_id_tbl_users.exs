defmodule Rms.Repo.Migrations.AddMakerIdCheckerIdTblUsers do
  use Ecto.Migration

  def up do
    alter table(:tbl_users) do
      add :maker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :checker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :login_attempt, :integer
      add :remote_ip, :string
    end
  end

  def down do
    alter table(:tbl_users) do
      remove :maker_id
      remove :checker_id
      remove :login_attempt
      remove :remote_ip
    end
  end
end
