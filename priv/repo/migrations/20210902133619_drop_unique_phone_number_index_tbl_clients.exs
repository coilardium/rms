defmodule Rms.Repo.Migrations.DropUniquePhoneNumberIndexTblClients do
  use Ecto.Migration

  def up do
    drop(index(:tbl_clients, [:phone_number], name: :unique_phone_number))

    create(
      unique_index(:tbl_clients, [:phone_number],
        name: :unique_phone_number,
        where: "phone_number is not null"
      )
    )
  end

  def down do
    drop(index(:tbl_clients, [:phone_number], name: :unique_phone_number))
    create(unique_index(:tbl_clients, [:phone_number], name: :unique_phone_number))
  end
end
