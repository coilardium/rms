defmodule Rms.Repo.Migrations.CreateTblSysException do
  use Ecto.Migration

  def change do
    create table(:tbl_sys_exception) do
      add :col_ind, :string
      add :error_msg, :string
      add :error_code, :string

      timestamps()
    end
  end
end
