defmodule Rms.SystemUtilities.TariffLine do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @cast_fields [
    :start_dt,
    :checker_id,
    :maker_id,
    :commodity_id,
    :currency_id,
    :pay_type_id,
    :surcharge_id,
    :orig_station_id,
    :destin_station_id,
    :client_id,
    :category,
    :status
  ]

  @required [
    :commodity_id,
    :currency_id,
    :pay_type_id,
    :surcharge_id,
    :orig_station_id,
    :destin_station_id,
    :client_id,
    :category
  ]

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_tariff_line" do
    field :nll_2005, :decimal
    field :nlpi, :decimal
    field :status, :string, default: "D"
    field :rsz, :decimal
    field :tfr, :decimal
    field :total, :float
    field :tzr, :decimal
    field :tzr_project, :decimal
    field :additional_chg, :decimal
    field :start_dt, :date
    field :addional_chg, :decimal
    field :category, :string

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :commodity, Rms.SystemUtilities.Commodity, foreign_key: :commodity_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id
    belongs_to :pay_type, Rms.SystemUtilities.PaymentType, foreign_key: :pay_type_id, type: :id
    belongs_to :surcharge, Rms.SystemUtilities.Surchage, foreign_key: :surcharge_id, type: :id

    belongs_to :orig_station, Rms.SystemUtilities.Station,
      foreign_key: :orig_station_id,
      type: :id

    belongs_to :destin_station, Rms.SystemUtilities.Station,
      foreign_key: :destin_station_id,
      type: :id

    belongs_to :client, Rms.Accounts.Clients, foreign_key: :client_id, type: :id

    has_many :rates, Rms.SystemUtilities.TariffLineRate,
      foreign_key: :tariff_id,
      on_delete: :nilify_all

    timestamps()
  end

  @doc false
  def changeset(tariff_line, attrs) do
    tariff_line
    |> cast(attrs, @cast_fields)
    |> validate_required(@required)
    # |> validate_number(:additional_chg,
    #   greater_than: Decimal.new(0),
    #   message: " should be greater than 0"
    # )
    |> unique_constraint(:commodity_id,
      name: :unique_tariff_line,
      message: " already exists for the selected customer and routes"
    )
  end

  defmodule Localtime do
    def autogenerate, do: Timex.local() |> DateTime.truncate(:second) |> DateTime.to_naive()
  end
end
