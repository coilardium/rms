defmodule Rms.Repo.Migrations.AlterUniqueConstraintInTblTransportType do
  use Ecto.Migration

  def up do
    # drop(index(:tbl_transport_type, [:code], name: :unique_code))
    # create(unique_index(:tbl_transport_type, [:code], name: :unique_code, where: "code is not null"))
  end

  def down do
    # drop(index(:tbl_transport_type, [:code], name: :unique_code))
    # create(unique_index(:tbl_transport_type, [:code], name: :unique_code))
  end
end
