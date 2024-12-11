defmodule Rms.Order.Movement do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @cast [
    :commodity_id,
    :consignee_id,
    :station_code,
    :consigner_id,
    :batch_id,
    :consignment_date,
    :container_no,
    :dead_loco,
    :destin_station_id,
    :loco_id,
    :movement_date,
    :movement_time,
    :netweight,
    :train_list_no,
    :status,
    :movement_origin_id,
    :movement_reporting_station_id,
    :movement_destination_id,
    :origin_station_id,
    :payer_id,
    :sales_order,
    :loco_no,
    :train_no,
    :wagon_id,
    :consignment_id,
    :maker_id,
    :checker_id,
    :manual_matching,
    :comment,
    :user_region_id,
    :has_consignmt,
    :modifier_id,
    :invoice_no,
    :customer_id,
    :detach_reason,
    :detach_date,
    :attached_date,
    :arrival_date
  ]

  @required [
    :movement_origin_id,
    :movement_date,
    :movement_time,
    :status,
    :movement_reporting_station_id,
    :movement_destination_id,
    :train_no,
    :wagon_id,
    :maker_id
  ]

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_movement" do
    field :consignment_date, :date
    field :container_no, :string
    field :dead_loco, :string
    field :status, :string, default: "PENDING_VERIFICATION"
    field :invoice_no, :string
    field :movement_date, :date
    field :movement_time, :string
    field :netweight, :string
    field :station_code, :string
    field :sales_order, :string
    field :comment, :string
    field :loco_no, :string
    field :train_no, :string
    field :train_list_no, :string
    field :manual_matching, :string, default: "NO"
    field :has_consignmt, :string, default: "YES"
    field :detach_reason, :string
    field :detach_date, :date
    field :attached_date, :date
    field :arrival_date, :date

    belongs_to :origin_station, Rms.SystemUtilities.Station,
      foreign_key: :origin_station_id,
      type: :id

    belongs_to :destin_station, Rms.SystemUtilities.Station,
      foreign_key: :destin_station_id,
      type: :id

    belongs_to :commodity, Rms.SystemUtilities.Commodity, foreign_key: :commodity_id, type: :id
    belongs_to :loco, Rms.Locomotives.Locomotive, foreign_key: :loco_id, type: :id
    belongs_to :payer, Rms.Accounts.Clients, foreign_key: :payer_id, type: :id
    belongs_to :modifier, Rms.Accounts.User, foreign_key: :modifier_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :wagon, Rms.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id
    belongs_to :consignment, Rms.Order.Consignment, foreign_key: :consignment_id, type: :id
    belongs_to :batch, Rms.Order.Batch, foreign_key: :batch_id, type: :id

    belongs_to :movement_destination, Rms.SystemUtilities.Station,
      foreign_key: :movement_destination_id,
      type: :id

    belongs_to :movement_reporting_station, Rms.SystemUtilities.Station,
      foreign_key: :movement_reporting_station_id,
      type: :id

    belongs_to :movement_origin, Rms.SystemUtilities.Station,
      foreign_key: :movement_origin_id,
      type: :id

    belongs_to :consignee, Rms.Accounts.Clients, foreign_key: :consignee_id, type: :id
    belongs_to :consigner, Rms.Accounts.Clients, foreign_key: :consigner_id, type: :id
    belongs_to :customer, Rms.Accounts.Clients, foreign_key: :customer_id, type: :id
    belongs_to :user_region, Rms.Accounts.UserRegion, foreign_key: :user_region_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(movement, attrs) do
    movement
    |> cast(attrs, @cast)
    |> validate_required(@required)
    |> unique_constraint(:wagon_id,
      name: :unique_station_wagon,
      message: "already exists with the same Station code"
    )
    |> unique_constraint(:wagon_id,
      name: :unique_train_list_wagon,
      message: "already exists with same the Train list number"
    )
    |> unique_constraint(:wagon_id,
      name: :unique_train_no_wagon,
      message: "already exists with same the Train number"
    )
    |> check_movement_type()
  end

  defp check_movement_type(%Ecto.Changeset{valid?: true} = changeset) do
    case get_field(changeset, :has_consignmt) do
      "NO" ->
        search_for_consignment(changeset)

      _consignment ->
        does_consignment_exist?(changeset)
    end
  end

  defp check_movement_type(changeset), do: changeset

  defp does_consignment_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    wagon_id = get_field(changeset, :wagon_id)
    invoice_no = get_field(changeset, :invoice_no)

    case invoice_no do
      nil ->
        changeset

      _ ->
        case Rms.Order.search_for_consignment_by_station_code(wagon_id, String.trim(invoice_no)) do
          nil ->
            wagon = Rms.SystemUtilities.get_wagon!(wagon_id).code

            add_error(
              changeset,
              :consignment,
              "does not exist for Wagon No. \"#{wagon}\" and PZ Code  \"#{invoice_no}\"  "
            )

          consignment ->
            change(changeset,
              consignment_id: consignment.id,
              commodity_id: consignment.commodity_id,
              consignment_date: consignment.document_date,
              destin_station_id: consignment.final_destination_id,
              origin_station_id: consignment.origin_station_id,
              consignee_id: consignment.consignee_id,
              consigner_id: consignment.consigner_id,
              station_code: consignment.station_code,
              payer_id: consignment.payer_id,
              consignment_date: consignment.document_date,
              customer_id: consignment.customer_id
            )
        end
    end
  end

  defp search_for_consignment(%Ecto.Changeset{valid?: true} = changeset) do
    wagon_id = get_field(changeset, :wagon_id)
    commodity_id = get_field(changeset, :commodity_id)
    consignment_date = get_field(changeset, :consignment_date)
    destin_station_id = get_field(changeset, :destin_station_id)
    origin_station_id = get_field(changeset, :origin_station_id)
    consignee_id = get_field(changeset, :consignee_id)

      case consignee_id do
        nil -> changeset

        _ ->
          case Rms.Order.search_for_consignment(wagon_id, commodity_id, consignment_date, origin_station_id, destin_station_id, consignee_id) do
            nil ->
              changeset

            consignment ->
              change(changeset,
                consignment_id: consignment.id,
                station_code: consignment.station_code,
                sales_order: consignment.sale_order
              )
          end
      end
  end

end
