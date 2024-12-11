defmodule Rms.Order.Consignment do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @cast [
    :capture_date,
    :code,
    :customer_ref,
    :document_date,
    :sale_order,
    :station_code,
    :status,
    :vat_amount,
    :invoice_no,
    :rsz,
    :nlpi,
    :nll_2005,
    :tfr,
    :tzr,
    :tzr_project,
    :additional_chg,
    :final_destination_id,
    :origin_station_id,
    :reporting_station_id,
    :commodity_id,
    :consignee_id,
    :consigner_id,
    :customer_id,
    :acc_checker_id,
    :verifier_id,
    :payer_id,
    :tarrif_id,
    :maker_id,
    :batch_id,
    :wagon_id,
    :checker_id,
    :comment,
    :capacity_tonnes,
    :actual_tonnes,
    :tariff_tonnage,
    :container_no,
    :tariff_destination_id,
    :tariff_origin_id,
    :invoice_date,
    :invoice_amount,
    :invoice_term,
    :invoice_currency_id,
    :route_id,
    :vat_applied,
    :grand_total,
    :total,
    :manual_matching,
    :user_region_id,
    :modifier_id
  ]

  @required [
    :capture_date,
    :document_date,
    :sale_order,
    :station_code,
    :status,
    :final_destination_id,
    :origin_station_id,
    :reporting_station_id,
    :commodity_id,
    :consignee_id,
    :consigner_id,
    :payer_id,
    :maker_id,
    :wagon_id,
    :tarrif_id,
    # :capacity_tonnes,
    :actual_tonnes
    # :tariff_tonnage,
    # :container_no
  ]

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_consignments" do
    field :capture_date, :date
    field :code, :string
    field :customer_ref, :string
    field :document_date, :date
    field :sale_order, :string
    field :station_code, :string
    field :status, :string, default: "PENDING_APPROVAL"
    field :vat_amount, :decimal
    field :invoice_no, :string
    field :rsz, :decimal
    field :nlpi, :decimal
    field :nll_2005, :decimal
    field :tfr, :decimal
    field :tzr, :decimal
    field :tzr_project, :decimal
    field :additional_chg, :decimal
    field :comment, :string
    field :capacity_tonnes, :decimal
    field :actual_tonnes, :decimal
    field :tariff_tonnage, :decimal
    field :container_no, :string
    field :invoice_date, :date
    field :invoice_amount, :decimal
    field :invoice_term, :string
    field :vat_applied, :string, default: "NO"
    field :grand_total, :decimal
    field :total, :decimal
    field :manual_matching, :string, default: "NO"

    belongs_to :invoice_currency, Rms.SystemUtilities.Currency,
      foreign_key: :invoice_currency_id,
      type: :id

    belongs_to :tariff_destination, Rms.SystemUtilities.Station,
      foreign_key: :tariff_destination_id,
      type: :id

    belongs_to :tariff_origin, Rms.SystemUtilities.Station,
      foreign_key: :tariff_origin_id,
      type: :id

    belongs_to :final_destin, Rms.SystemUtilities.Station,
      foreign_key: :final_destination_id,
      type: :id

    belongs_to :origin_station, Rms.SystemUtilities.Station,
      foreign_key: :origin_station_id,
      type: :id

    belongs_to :reporting_station, Rms.SystemUtilities.Station,
      foreign_key: :reporting_station_id,
      type: :id

    belongs_to :commodity, Rms.SystemUtilities.Commodity, foreign_key: :commodity_id, type: :id
    belongs_to :consignee, Rms.Accounts.Clients, foreign_key: :consignee_id, type: :id
    belongs_to :consigner, Rms.Accounts.Clients, foreign_key: :consigner_id, type: :id
    belongs_to :customer, Rms.Accounts.Clients, foreign_key: :customer_id, type: :id
    belongs_to :payer, Rms.Accounts.Clients, foreign_key: :payer_id, type: :id
    belongs_to :tarrif, Rms.SystemUtilities.TariffLine, foreign_key: :tarrif_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :acc_checker, Rms.Accounts.User, foreign_key: :acc_checker_id, type: :id
    belongs_to :verifier, Rms.Accounts.User, foreign_key: :verifier_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :modifier, Rms.Accounts.User, foreign_key: :modifier_id, type: :id
    belongs_to :wagon, Rms.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id
    belongs_to :batch, Rms.Order.Batch, foreign_key: :batch_id, type: :id
    belongs_to :route, Rms.SystemUtilities.TrainRoute, foreign_key: :route_id, type: :id
    belongs_to :user_region, Rms.Accounts.UserRegion, foreign_key: :user_region_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(consignment, attrs) do
    consignment
    |> cast(attrs, @cast)
    |> validate_required(@required)
    |> unique_constraint(:wagon_id,
      name: :unique_container_no_wagon,
      message: "already exists with the Container Number "
    )
    |> unique_constraint(:wagon_id,
      name: :unique_sales_order_wagon,
      message: "already exists with same the Sales Order Number"
    )
    |> does_route_exist?()
    |> is_empty_wagon?()
  end

  defp does_route_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    origin = get_field(changeset, :origin_station_id)
    destin = get_field(changeset, :final_destination_id)

    case Rms.SystemUtilities.search_for_route(origin, destin) do
      nil ->
        origin_stat = Rms.SystemUtilities.get_station!(origin)
        destin_stat = Rms.SystemUtilities.get_station!(destin)

        add_error(
          changeset,
          :route,
          "does not exist for origin station \"#{origin_stat.description}\" and destination station \"#{destin_stat.description}\" "
        )

      route ->
        change(changeset, route_id: route.id)
    end
  end

  defp does_route_exist?(changeset), do: changeset

  defp is_empty_wagon?(
         %Ecto.Changeset{
           valid?: true,
           changes: %{tariff_tonnage: %Decimal{coef: 0}, actual_tonnes: %Decimal{coef: 0}}
         } = changeset
       ) do
    container_no = get_field(changeset, :container_no)

    case container_no do
      nil ->
        empty_commodity(changeset)

      _ ->
        changeset
    end
  end

  defp is_empty_wagon?(changeset), do: changeset

  defp empty_commodity(changeset) do
    case Rms.SystemUtilities.empty_commodity_lookup() do
      nil ->
        add_error(changeset, :Empty, " Commodity does not exists")

      commodity ->
        put_change(changeset, :commodity_id, commodity.id)
    end
  end
end
