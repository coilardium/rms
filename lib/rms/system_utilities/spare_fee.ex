defmodule Rms.SystemUtilities.SpareFee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_spare_fees" do
    field :amount, :decimal
    field :code, :string
    field :start_date, :date
    field :cataloge, :string
    # field :spare_id, :id
    # field :currency_id, :id
    field :status, :string, default: "D"

    belongs_to :spare, Rms.SystemUtilities.Spare, foreign_key: :spare_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :railway_admin, type: :id

    timestamps()
  end

  @doc false
  def changeset(spare_fee, attrs) do
    spare_fee
    |> cast(attrs, [
      :amount,
      :start_date,
      :maker_id,
      :checker_id,
      :status,
      :currency_id,
      :spare_id,
      :cataloge,
      :railway_admin
    ])
    |> validate_required([:amount, :start_date, :railway_admin, :currency_id])
  end
end
