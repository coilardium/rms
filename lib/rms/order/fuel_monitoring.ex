defmodule Rms.Order.FuelMonitoring do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @cast [
    :loco_no,
    :train_number,
    :requisition_no,
    :seal_number_at_arrival,
    :seal_number_at_depture,
    :seal_color_at_arrival,
    :seal_color_at_depture,
    :time,
    :balance_before_refuel,
    :approved_refuel,
    :quantity_refueled,
    :deff_ctc_actual,
    :reading_after_refuel,
    :bp_meter_before,
    :bp_meter_after,
    :reading,
    :fuel_consumed,
    :consumption_per_km,
    :fuel_rate,
    :section,
    :date,
    :week_no,
    :total_cost,
    :comment,
    :status,
    :batch_id,
    :loco_id,
    # :loco_driver_id,
    :train_type_id,
    :commercial_clerk_id,
    :depo_refueled_id,
    :train_destination_id,
    :train_origin_id,
    :maker_id,
    :checker_id,
    :km_to_destin,
    :meter_at_destin,
    :oil_rep_name,
    :asset_protection_officers_name,
    :other_refuel,
    :other_refuel_no,
    :stn_foreman,
    :refuel_type,
    :section_id,
    :user_region_id,
    :depo_stn,
    :user_station_id,
    :fuel_blc_figures,
    :ctc_datestamp,
    :ctc_time,
    :fuel_blc_words,
    :litres_in_words,
    :loco_engine_capacity,
    :locomotive_id,
    :yard_master_id,
    :locomotive_type,
    :locomotive_driver_id,
    :shunt,
    :driver_name,
    :commercial_clk_name,
    :yard_master_name,
    :controllers_name
  ]

  @required [
    # :loco_no,
    # :train_number,
    # :requisition_no,
    # :seal_number_at_arrival,
    # :seal_number_at_depture,
    # :seal_color_at_arrival,
    # :seal_color_at_depture,
    # :time,
    # :balance_before_refuel,
    # :approved_refuel,
    # :quantity_refueled,
    # :deff_ctc_actual,
    # :reading_after_refuel,
    # :bp_meter_before,
    # :bp_meter_after,
    # :reading,
    # :Km_to_destination,
    # :fuel_consumed,
    # :consumption_per_km,
    # :fuel_rate,
    # :section,
    # :date,
    # :week_no,
    # :total_cost,
    # # :comment,
  ]

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_fuel_monitoring" do
    field :Km_to_destination, :decimal
    field :approved_refuel, :decimal
    field :balance_before_refuel, :decimal
    field :bp_meter_after, :decimal
    field :bp_meter_before, :decimal
    field :comment, :string
    field :consumption_per_km, :decimal
    field :date, :date
    field :deff_ctc_actual, :decimal
    field :fuel_consumed, :decimal
    field :fuel_rate, :decimal
    field :loco_no, :string
    field :quantity_refueled, :decimal
    field :reading, :decimal
    field :reading_after_refuel, :decimal
    field :requisition_no, :string
    field :seal_color_at_arrival, :string
    field :seal_color_at_depture, :string
    field :seal_number_at_arrival, :string
    field :seal_number_at_depture, :string
    field :section, :string
    field :time, :string
    field :total_cost, :decimal
    field :train_number, :string
    field :week_no, :string
    field :status, :string, default: "PENDING_CONTROL"
    field :km_to_destin, :decimal
    field :meter_at_destin, :decimal
    field :oil_rep_name, :string
    field :asset_protection_officers_name, :string
    field :other_refuel, :string
    field :other_refuel_no, :string
    field :stn_foreman, :string
    field :fuel_blc_figures, :string
    field :ctc_datestamp, :date
    field :ctc_time, :string
    field :fuel_blc_words, :string
    field :litres_in_words, :string
    field :loco_engine_capacity, :decimal
    field :locomotive_type, :string
    field :shunt, :string
    field :driver_name, :string
    field :commercial_clk_name, :string
    field :yard_master_name, :string
    field :controllers_name, :string

    belongs_to :depo_refueled, Rms.SystemUtilities.Rates,
      foreign_key: :depo_refueled_id,
      type: :id

    belongs_to :depo_station, Rms.SystemUtilities.Station, foreign_key: :depo_stn, type: :id

    belongs_to :train_destination, Rms.SystemUtilities.Station,
      foreign_key: :train_destination_id,
      type: :id

    belongs_to :train_origin, Rms.SystemUtilities.Station,
      foreign_key: :train_origin_id,
      type: :id

    belongs_to :depo_rate, Rms.SystemUtilities.Station, foreign_key: :depo_stn_rate, type: :id
    belongs_to :commercial_clerk, Rms.Accounts.User, foreign_key: :commercial_clerk_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :train_type, Rms.SystemUtilities.TrainType, foreign_key: :train_type_id, type: :id
    # belongs_to :loco_driver, Rms.Accounts.LocoDriver, foreign_key: :loco_driver_id, type: :id
    belongs_to :loco, Rms.Locomotives.LocomotiveType, foreign_key: :loco_id, type: :id
    belongs_to :batch, Rms.Order.Batch, foreign_key: :batch_id, type: :id

    belongs_to :refueling_type, Rms.SystemUtilities.Refueling,
      foreign_key: :refuel_type,
      type: :id

    belongs_to :section_type, Rms.SystemUtilities.Section, foreign_key: :section_id, type: :id
    belongs_to :user_region, Rms.Accounts.UserRegion, foreign_key: :user_region_id, type: :id
    belongs_to :station, Rms.SystemUtilities.Station, foreign_key: :user_station_id, type: :id
    belongs_to :locomotive, Rms.Locomotives.Locomotive, foreign_key: :locomotive_id, type: :id
    belongs_to :yard_master, Rms.Accounts.User, foreign_key: :yard_master_id, type: :id
    belongs_to :loco_driver, Rms.Accounts.User, foreign_key: :locomotive_driver_id, type: :id


    timestamps()
  end

  @doc false
  def changeset(fuel_monitoring, attrs) do
    fuel_monitoring
    |> cast(attrs, @cast)
    |> validate_required(@required)
    |> unique_constraint(:requisition_no, name: :unique_requisition_no, message: "already exists")
  end
end
