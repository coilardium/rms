defmodule Rms.Tracking.Interchange do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_interchange" do
    field :accumulative_amount, :decimal, default: 0
    field :accumulative_days, :integer, default: 0
    field :total_accum_days, :integer, default: 0
    field :rate, :decimal
    field :comment, :string
    field :direction, :string
    field :status, :string, default: "ON_HIRE"
    field :auth_status, :string, default: "PENDING_APPROVAL"
    field :entry_date, :date
    field :exit_date, :date
    field :interchange_fee, :decimal
    field :uuid, :string
    field :off_hire_date, :date
    field :lease_period, :integer
    field :train_no, :string
    field :on_hire_date, :date
    field :hire_status, :string
    field :update_date, :date, default: Timex.today()
    field :bound, :string
    field :modification_reason, :string

    belongs_to :interchange_pnt, Rms.SystemUtilities.Station,
      foreign_key: :interchange_point,
      type: :id

    belongs_to :origin_station, Rms.SystemUtilities.Station,
      foreign_key: :origin_station_id,
      type: :id

    belongs_to :destination_station, Rms.SystemUtilities.Station,
      foreign_key: :destination_station_id,
      type: :id

    belongs_to :commodity, Rms.SystemUtilities.Commodity, foreign_key: :commodity_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :wagon, Rms.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id
    belongs_to :wagon_status, Rms.SystemUtilities.Status, foreign_key: :wagon_status_id, type: :id

    belongs_to :current_station, Rms.SystemUtilities.Station,
      foreign_key: :current_station_id,
      type: :id

    belongs_to :wagon_condition, Rms.SystemUtilities.Condition,
      foreign_key: :wagon_condition_id,
      type: :id

    belongs_to :administrator, Rms.Accounts.RailwayAdministrator,
      foreign_key: :adminstrator_id,
      type: :id

    belongs_to :interchange_fees, Rms.SystemUtilities.InterchangeFee,
      foreign_key: :interchange_fee_id,
      type: :id

    belongs_to :region, Rms.SystemUtilities.Region, foreign_key: :region_id, type: :id
    belongs_to :domain, Rms.SystemUtilities.Domain, foreign_key: :domain_id, type: :id
    belongs_to :locomotive, Rms.Locomotives.Locomotive, foreign_key: :locomotive_id, type: :id

    has_many :interchange_defects, Rms.Tracking.InterchangeDefect,
      foreign_key: :interchange_id,
      on_delete: :nilify_all

    timestamps()
  end

  @doc false
  def changeset(interchange, attrs) do
    interchange
    |> cast(attrs, [
      :comment,
      :direction,
      :off_hire_date,
      :lease_period,
      :auth_status,
      :status,
      :entry_date,
      :exit_date,
      :accumulative_days,
      :accumulative_amount,
      :interchange_fee,
      :maker_id,
      :checker_id,
      :wagon_id,
      :wagon_status_id,
      :commodity_id,
      :adminstrator_id,
      :interchange_point,
      :interchange_fee_id,
      :locomotive_id,
      :uuid,
      :origin_station_id,
      :destination_station_id,
      :train_no,
      :hire_status,
      :on_hire_date,
      :wagon_condition_id,
      :current_station_id,
      :update_date,
      :bound,
      :region_id,
      :total_accum_days,
      :rate,
      :modification_reason,
      :domain_id
    ])
    |> validate_required([
      :direction,
      :accumulative_days,
      :accumulative_amount,
      :maker_id,
      :wagon_id,
      :commodity_id,
      :adminstrator_id,
      :interchange_point,
      :current_station_id,
      :train_no
    ])
    |> does_interchange_fee_exist?()
  end

  defp does_interchange_fee_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    admin = get_field(changeset, :adminstrator_id)
    date = to_string(get_field(changeset, :on_hire_date))
    wagon = Rms.SystemUtilities.get_wagon!(get_field(changeset, :wagon_id))
    wagon_type = wagon.wagon_type_id

    case Rms.SystemUtilities.interchange_fee_lookup(String.slice(date, 0..-7), admin, wagon_type) do
      nil ->
        add_error(
          changeset,
          :Interchange,
          "Fee not maintained for Administrator"
        )

      fee ->
        change(changeset,
          interchange_fee_id: fee.id,
          rate: fee.amount,
          lease_period: fee.lease_period
        )
    end
  end

  defp does_interchange_fee_exist?(changeset), do: changeset
end
