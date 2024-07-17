defmodule Rms.Tracking.Auxiliary do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_interchange_auxiliary" do
    field :accumlative_days, :integer, default: 0
    field :total_accum_days, :integer, default: 0
    field :amount, :decimal
    field :dirction, :string
    field :off_hire_date, :date
    field :on_hire_date, :date
    field :received_date, :date
    field :sent_date, :date
    field :status, :string, default: "ON_HIRE"
    field :comment, :string
    field :update_date, :date
    field :auth_status, :string, default: "PENDING"
    field :equipment_code, :string
    field :archive_remark, :string
    field :archive_date, :date
    field :total_amount, :decimal
    field :modification_reason, :string
    field :wagon_code, :string, virtual: true
    # field :maker_id, :id
    # field :equipment_id, :id
    # field :admin_id, :id
    belongs_to :wagon, Rms.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id

    belongs_to :current_wagon, Rms.SystemUtilities.Wagon,
      foreign_key: :current_wagon_id,
      type: :id

    belongs_to :current_station, Rms.SystemUtilities.Station,
      foreign_key: :current_station_id,
      type: :id

    belongs_to :interchange_point, Rms.SystemUtilities.Station,
      foreign_key: :interchange_point_id,
      type: :id

    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :admin_id, type: :id
    belongs_to :equipment, Rms.SystemUtilities.Equipment, foreign_key: :equipment_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id

    belongs_to :equipment_rate, Rms.SystemUtilities.EquipmentRate,
      foreign_key: :equipment_rate_id,
      type: :id

    belongs_to :hire_off_user, Rms.Accounts.User, foreign_key: :hire_off_user_id, type: :id
    belongs_to :archive_user, Rms.Accounts.User, foreign_key: :archive_user_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(auxiliary, attrs) do
    auxiliary
    |> cast(attrs, [
      :amount,
      :sent_date,
      :received_date,
      :dirction,
      :status,
      :accumlative_days,
      :off_hire_date,
      :on_hire_date,
      :admin_id,
      :equipment_id,
      :maker_id,
      :currency_id,
      :equipment_rate_id,
      :hire_off_user_id,
      :comment,
      :update_date,
      :auth_status,
      :archive_user_id,
      :archive_remark,
      :archive_date,
      :equipment_code,
      :interchange_point_id,
      :current_station_id,
      :wagon_id,
      :total_amount,
      :current_wagon_id,
      :modification_reason,
      :total_accum_days,
      :wagon_code
    ])
    |> find_wagon_by_code()
    |> validate_required([:dirction, :status, :accumlative_days, :equipment_id, :wagon_id, :maker_id])
    |> unique_constraint(:wagon_id,
      name: :unique_interchange_auxiliary,
      message: "already exists with same Equipment"
    )
    |> does_auxiliary_fee_exist?()
  end

  defp does_auxiliary_fee_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    admin = get_field(changeset, :admin_id)
    equipment = get_field(changeset, :equipment_id)
    date = get_field(changeset, :received_date) || get_field(changeset, :sent_date)
    total_accum_days = get_field(changeset, :total_accum_days)

    case Rms.SystemUtilities.material_fee_lookup(date, admin, equipment) do
      nil ->
        add_error(
          changeset,
          :Rate,
          " not maintained for Administrator"
        )

      fee ->

        total_amount = Decimal.mult(fee.rate, total_accum_days)

        change(changeset,
          equipment_rate_id: fee.id,
          amount: fee.rate,
          currency_id: fee.currency_id,
          total_amount: total_amount
        )
    end
  end

  defp does_auxiliary_fee_exist?(changeset), do: changeset

 defp find_wagon_by_code( %Ecto.Changeset{valid?: true, changes: %{wagon_code: wagon_code}} = changeset) do

    case Rms.SystemUtilities.wagon_lookup(String.trim(wagon_code)) do
      nil ->
        add_error(changeset, :Wagon_ID, " \"#{wagon_code}\" does not exist")

      wagon ->
        change(changeset, wagon_id: wagon.id, current_wagon_id: wagon.id)
    end
  end

  defp find_wagon_by_code(changeset), do: changeset

end
