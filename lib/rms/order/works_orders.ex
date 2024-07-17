defmodule Rms.Order.WorksOrders do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_works_order_master" do
    field :area_name, :string
    field :comment, :string
    field :date_on_label, :date
    field :departure_date, :date
    field :departure_time, :string
    field :driver_name, :string
    field :load_date, :date
    field :off_loading_date, :date
    field :order_no, :string
    field :placed, :string
    field :supplied, :string
    field :time_arrival, :string
    field :time_out, :string
    field :train_no, :string
    field :yard_foreman, :string
    # field :client_id, :id
    # field :wagon_id, :id
    # field :commodity_id, :id
    # field :origin_station_id, :id
    # field :destin_station_id, :id

    belongs_to :origin_station, Rms.SystemUtilities.Station,
    foreign_key: :origin_station_id,
    type: :id

    belongs_to :destin_station, Rms.SystemUtilities.Station,
      foreign_key: :destin_station_id,
      type: :id

    belongs_to :commodity, Rms.SystemUtilities.Commodity, foreign_key: :commodity_id, type: :id
    belongs_to :client, Rms.Accounts.Clients, foreign_key: :client_id, type: :id
    belongs_to :wagon, Rms.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(works_orders, attrs) do
    works_orders
    |> cast(attrs, [:comment, :date_on_label, :off_loading_date, :order_no, :time_out, :yard_foreman, :area_name, :train_no, :driver_name, :departure_time, :departure_date, :time_arrival, :placed, :load_date, :supplied, :maker_id, :commodity_id, :client_id, :wagon_id, :destin_station_id, :origin_station_id ])
    |> validate_required([:comment, :time_out, :yard_foreman, :area_name, :train_no, :driver_name, :departure_time, :departure_date, :time_arrival, :placed, :supplied, :commodity_id, :client_id, :wagon_id, :destin_station_id, :origin_station_id])
  end
end
