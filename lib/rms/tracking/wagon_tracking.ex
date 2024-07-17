defmodule Rms.Tracking.WagonTracking do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @cast [
    :update_date,
    :departure,
    :arrival,
    :train_no,
    :yard_siding,
    :sub_category,
    :comment,
    :net_ton,
    :bound,
    :allocated_cust_id,
    :user_region_id,
    :on_hire,
    :wagon_id,
    :current_location_id,
    :condition_id,
    :commodity_id,
    :customer_id,
    :origin_id,
    :destination_id,
    :maker_id,
    :checker_id,
    :domain_id,
    :month,
    :year,
    :days_at,
    :total_accum_days,
    :defect_id,
    :file_name,
    :uuid,
    :wagon_code,
    :current_status_code,
    :domain_code,
    :condition_code,
    :tracking_type
  ]

  @required [
    :update_date,
    :departure,
    # :arrival,
    :train_no,
    # :comment,
    # :allocated_to_customer,
    # :hire,
    :wagon_id
    # :current_location_id, :id,
    # :condition_id, :id,
    # :commodity_id, :id,
    # :customer_id,
    # :origin_id, :id,
    # :destination_id, :id,
    # :maker_id, :id,
    # :defect_id, :id
    # :checker_id, :id,
  ]

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_wagon_tracking" do
    field :allocated_to_customer, :string
    field :total_accum_days, :integer, default: 0
    field :arrival, :string
    field :bound, :string
    field :comment, :string
    field :departure, :string
    field :on_hire, :string, default: "N"
    field :net_ton, :decimal
    field :sub_category, :string
    field :train_no, :string
    field :update_date, :date
    field :yard_siding, :string
    field :month, :string
    field :year, :string
    field :file_name, :string
    field :uuid, :string
    field :days_at, :integer, default: 0
    field :wagon_code, :string, virtual: true
    field :current_status_code, :string, virtual: true
    field :domain_code, :string, virtual: true
    field :condition_code, :string, virtual: true
    field :tracking_type, :string, virtual: true
    # field :wagon_id, :id
    # field :current_location_id, :id
    # field :condition_id, :i
    # field :commodity_id, :id
    # field :customer_id, :id
    # field :origin_id, :id
    # field :destination_id, :id
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :defects, Rms.SystemUtilities.Defect, foreign_key: :defect_id, type: :id
    belongs_to :destination, Rms.SystemUtilities.Station, foreign_key: :destination_id, type: :id
    belongs_to :origin, Rms.SystemUtilities.Station, foreign_key: :origin_id, type: :id

    belongs_to :location, Rms.SystemUtilities.Station,
      foreign_key: :current_location_id,
      type: :id

    belongs_to :commodity, Rms.SystemUtilities.Commodity, foreign_key: :commodity_id, type: :id
    belongs_to :customer, Rms.Accounts.Clients, foreign_key: :customer_id, type: :id

    belongs_to :allocated_customer, Rms.Accounts.Clients,
      foreign_key: :allocated_cust_id,
      type: :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :wagon, Rms.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id
    belongs_to :condition, Rms.SystemUtilities.Condition, foreign_key: :condition_id, type: :id
    belongs_to :domain, Rms.SystemUtilities.Domain, foreign_key: :domain_id, type: :id
    belongs_to :user_region, Rms.Accounts.UserRegion, foreign_key: :user_region_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(wagon_tracking, attrs) do
    wagon_tracking
    |> cast(attrs, @cast)
    # |> find_wagon_by_code()
    # |> find_current_status_by_code()
    # |> find_domain_by_code()
    # |> find_conditin_by_code()
    |> validate_required(@required)
    |> does_movement_exist?()
    |> unique_constraint(:update_date, name: :unique_wagon_tracker, message: "already exists")
  end

  defp does_movement_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    train_no = get_field(changeset, :train_no)
    wagon_id = get_field(changeset, :wagon_id)

    case Rms.Order.search_for_train_list_entry(wagon_id, train_no) do
      nil ->
        # add_error(changeset, :train_no, " \"#{train_no}\" does not exist")
        does_train_exist?(train_no, changeset)

      movement ->
        change(changeset,
          commodity_id: movement.commodity_id,
          customer_id: movement.customer_id,
          origin_id: movement.origin_station_id,
          destination_id: movement.destin_station_id
        )
    end
  end

  defp does_movement_exist?(changeset), do: changeset

  defp does_train_exist?(train_no, changeset) do
    case Rms.Order.search_for_train(train_no) do
      nil ->
        add_error(changeset, :train_no, " \"#{train_no}\" does not exist")

      movement ->
        tracking_type(changeset, movement)
    end
  end

  defp tracking_type(changeset, movement) do
    case get_field(changeset, :tracking_type) do
      "SINGLE" ->
        change(changeset,
          origin_id: movement.origin_station_id,
          destination_id: movement.destin_station_id
        )

      _ ->
        changeset
    end
  end

  # defp find_wagon_by_code(
  #        %Ecto.Changeset{valid?: true, changes: %{wagon_code: wagon_code}} = changeset
  #      ) do
  #   case Rms.SystemUtilities.wagon_lookup(wagon_code) do
  #     nil ->
  #       add_error(changeset, :wagon_code, " \"#{wagon_code}\" does not exist")

  #     wagon ->
  #       change(changeset, wagon_id: wagon.id)
  #   end
  # end

  # defp find_wagon_by_code(changeset), do: changeset

  # defp find_current_status_by_code(
  #        %Ecto.Changeset{valid?: true, changes: %{current_status_code: code}} = changeset
  #      ) do
  #   case Rms.SystemUtilities.wagon_status_lookup(code) do
  #     nil ->
  #       add_error(changeset, :current_status_code, " \"#{code}\" does not exist")

  #     current_status ->
  #       change(changeset, departure: to_string(current_status.id))
  #   end
  # end

  # defp find_current_status_by_code(changeset), do: changeset

  # defp find_domain_by_code(
  #        %Ecto.Changeset{valid?: true, changes: %{domain_code: code}} = changeset
  #      ) do
  #   case Rms.SystemUtilities.domain_lookup(code) do
  #     nil ->
  #       add_error(changeset, :domain_code, " \"#{code}\" does not exist")

  #     domain ->
  #       change(changeset, domain_id: domain.id)
  #   end
  # end

  # defp find_domain_by_code(changeset), do: changeset

  # defp find_conditin_by_code(
  #        %Ecto.Changeset{valid?: true, changes: %{condition_code: code}} = changeset
  #      ) do
  #   case Rms.SystemUtilities.wagon_condition_lookup(code) do
  #     nil ->
  #       add_error(changeset, :condition_code, " \"#{code}\" does not exist")

  #     condition ->
  #       change(changeset, condition_id: condition.id)
  #   end
  # end

  # defp find_conditin_by_code(changeset), do: changeset
end
