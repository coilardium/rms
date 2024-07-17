defmodule Rms.Repo.Migrations.AddUniqueConstraintCodeToTblDomain do
  use Ecto.Migration

  def up do
    create(
      unique_index(:tbl_domain, [:code], name: :unique_domain_code, where: "code is not null")
    )
  end

  def down do
    drop(index(:tbl_domain, [:code], name: :unique_domain_code))
  end
end
