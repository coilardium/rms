defmodule Rms.Repo.Migrations.AddUniqueConstraintLoadStatusToTblComodity do
  use Ecto.Migration

  def up do
    create(
      unique_index(:tbl_commodity, [:load_status],
        name: :unique_load_status,
        where: "load_status = 'E' "
      )
    )
  end

  def down do
    drop(index(:tbl_commodity, [:load_status], name: :unique_load_status))
  end
end
