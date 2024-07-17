defmodule Rms.SystemUtilities.TrainRoute do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_train_routes" do
    field :code, :string
    field :description, :string
    # field :destination_station, :string
    field :distance, :decimal
    # field :operator, :string
    # field :origin_station, :string
    field :status, :string, default: "D"
    # field :transport_type, :string
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :destination, Rms.SystemUtilities.Station,
      foreign_key: :destination_station,
      type: :id

    belongs_to :origin, Rms.SystemUtilities.Station, foreign_key: :origin_station, type: :id

    belongs_to :transport, Rms.SystemUtilities.TransportType,
      foreign_key: :transport_type,
      type: :id

    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :operator, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(train_route, attrs) do
    train_route
    |> cast(attrs, [
      :code,
      :description,
      :origin_station,
      :destination_station,
      :status,
      :transport_type,
      :distance,
      :operator,
      :maker_id,
      :checker_id
    ])
    |> validate_required([
      :description,
      :origin_station,
      :destination_station,
      :status,
      :transport_type,
      :distance,
      :operator
    ])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
