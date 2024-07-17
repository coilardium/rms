defmodule Rms.SystemUtilities.Distance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_distance" do
    # field :destin, :string
    field :distance, :decimal
    # field :station_orig, :string
    field :status, :string, default: "D"

    belongs_to :destination, Rms.SystemUtilities.Station, foreign_key: :destin, type: :id
    belongs_to :origin, Rms.SystemUtilities.Station, foreign_key: :station_orig, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(distance, attrs) do
    distance
    |> cast(attrs, [:station_orig, :destin, :distance, :maker_id, :checker_id, :status])
    |> validate_required([:station_orig, :destin, :distance])
  end
end
