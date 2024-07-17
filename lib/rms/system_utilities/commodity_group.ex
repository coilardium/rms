defmodule Rms.SystemUtilities.CommodityGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_commodity_group" do
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"
    # field :maker_id, :id
    # field :checker_id, :id
    # field :commodity_type, :string

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(commodity_group, attrs) do
    commodity_group
    |> cast(attrs, [:code, :description, :status, :maker_id, :checker_id])
    |> validate_required([:description, :status, :maker_id])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:code, name: :unique_group_code, message: " already exists")
  end
end
