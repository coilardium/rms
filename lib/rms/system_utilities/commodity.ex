defmodule Rms.SystemUtilities.Commodity do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  @primary_key {:id, :integer, autogenerate: false}
  schema "tbl_commodity" do
    field :code, :string
    field :description, :string
    field :is_container, :string, default: "N"
    field :status, :string, default: "D"
    field :load_status, :string
    field :commodity_code, :string

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    belongs_to :commodity_group, Rms.SystemUtilities.CommodityGroup,
      foreign_key: :com_group_id,
      type: :id

    timestamps()
  end

  @doc false
  def changeset(commodity, attrs) do
    commodity
    |> cast(attrs, [
      :code,
      :description,
      :is_container,
      :status,
      :maker_id,
      :checker_id,
      :com_group_id,
      :load_status,
      :commodity_code
    ])
    # |> validate_required([:description, :is_container, :status, :maker_id, :com_group_id])
    |> validate_inclusion(:status, ~w(A D))
    # |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    # |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    # |> unique_constraint(:code, name: :unique_code, message: "already exists")
    # |> unique_constraint(:description, name: :unique_description, message: "already exists")
    # |> unique_constraint(:load_status, name: :unique_load_status, message: "already exists")
  end
end
