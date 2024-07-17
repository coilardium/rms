defmodule Rms.Accounts.Clients do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_clients" do
    field :address, :string
    field :client_account, :string
    field :client_name, :string
    field :email, :string
    field :phone_number, :string
    field :status, :string, default: "D"
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(clients, attrs) do
    clients
    |> cast(attrs, [
      :client_name,
      :address,
      :phone_number,
      :email,
      :status,
      :maker_id,
      :checker_id
    ])
    |> validate_required([:client_name, :address, :phone_number, :email, :status])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:phone_number, min: 1, max: 20, message: " should be 1 - 10 character(s)")
    |> unique_constraint(:phone_number, name: :unique_phone_number, message: "already exists")
    |> unique_constraint(:client_name, name: :unique_client_name, message: "already exists")
    # |> unique_constraint(:client_account, name: :unique_client_account, message: "already exists")
    |> unique_constraint(:email, name: :unique_email, message: "already exists")
  end
end
