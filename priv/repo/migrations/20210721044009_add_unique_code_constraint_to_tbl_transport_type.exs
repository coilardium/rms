defmodule Rms.Repo.Migrations.AddUniqueCodeConstraintToTblTransportType do
  use Ecto.Migration

  def up do
    create(
      unique_index(:tbl_transport_type, [:code],
        name: :unique_transport_code,
        where: "code is not null"
      )
    )
  end

  def down do
    drop(index(:tbl_transport_type, [:code], name: :unique_transport_code))
  end
end
