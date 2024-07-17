defmodule Rms.SystemUtilities.Station do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  @primary_key {:id, :integer, autogenerate: false}
  schema "tbl_stations" do
    field :acronym, :string
    field :description, :string
    field :station_id, :string
    field :status, :string, default: "D"
    field :interchange_point, :string, default: "NO"
    field :station_code, :string
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :owner, Rms.Accounts.RailwayAdministrator, foreign_key: :owner_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :domain, Rms.SystemUtilities.Domain, foreign_key: :domain_id, type: :id
    belongs_to :region, Rms.SystemUtilities.Region, foreign_key: :region_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(stations, attrs) do
    stations
    |> cast(attrs, [
      :acronym,
      :description,
      :station_id,
      :status,
      :owner_id,
      :maker_id,
      :interchange_point,
      :domain_id,
      :region_id,
      :checker_id,
      :station_code
    ])
    |> validate_required([:description, :interchange_point])
    # |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:acronym, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:station_id, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:acronym, name: :unique_acronym, message: "already exists")
  end
end
