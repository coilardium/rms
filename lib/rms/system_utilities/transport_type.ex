defmodule Rms.SystemUtilities.TransportType do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_transport_type" do
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"
    field :transport_type, :string
    field :catgory, :string
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(transport_type, attrs) do
    transport_type
    |> cast(attrs, [
      :code,
      :transport_type,
      :description,
      :status,
      :maker_id,
      :checker_id,
      :catgory
    ])
    |> validate_required([:transport_type, :description, :status])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
