defmodule Rms.Repo.Migrations.AddComGroupIdToTblComodity do
  use Ecto.Migration

  def up do
    alter table(:tbl_commodity) do
      remove_if_exists(:com_group_id, :string)
      add :com_group_id, references(:tbl_commodity_group, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_commodity) do
      remove :com_group_id
    end
  end
end
