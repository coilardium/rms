defmodule Rms.Repo.Migrations.AddArchiveRemarkArchiveUserIdArchiveDate do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_auxiliary) do
      add :archive_user_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :archive_remark, :string
      add :archive_date, :date
    end
  end

  def down do
    alter table(:tbl_interchange_auxiliary) do
      remove :archive_user_id
      remove :archive_remark
      remove :archive_date
    end
  end
end
