defmodule Rms.Accounts.UserRegion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]

  schema "tbl_user_region" do
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :station, Rms.SystemUtilities.Station, foreign_key: :station_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(user_region, attrs) do
    user_region
    |> cast(attrs, [:description, :code, :status, :maker_id, :checker_id, :station_id])
    |> validate_required([:station_id, :code])
    |> unique_constraint(:description)
    |> unique_constraint(:station_id)
    |> unique_constraint(:code)
  end
end
