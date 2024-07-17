defmodule Rms.SystemUtilities.HaulageRate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_haulage_rates" do
    field :distance, :decimal
    field :rate, :decimal
    field :rate_type, :string
    field :start_date, :date
    field :status, :string
    field :category, :string
    # field :admin_id, :id
    # field :maker_id, :id
    # field :checker_id, :id
    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :admin_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(haulage_rate, attrs) do
    haulage_rate
    |> cast(attrs, [
      :rate,
      :start_date,
      :status,
      :rate_type,
      :distance,
      :admin_id,
      :currency_id,
      :maker_id,
      :checker_id,
      :category
    ])
    |> validate_required([
      :rate,
      :start_date,
      :status,
      :rate_type,
      :category,
      :currency_id,
      :admin_id
    ])
  end
end
