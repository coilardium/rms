defmodule Rms.SystemUtilities.CompanyInfo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_company_info" do
    field :company_address, :string
    field :company_telephone, :string
    field :company_email, :string
    field :company_name, :string
    field :login_attempts, :integer
    field :password_expiry_days, :integer
    field :status, :string, default: "D"
    field :on_hire_max_period, :integer
    field :vat, :decimal
    field :unmatched_aging_period, :integer
    field :wagon_mvt_status, :integer
    field :free_days, :integer

    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :prefered_ccy_id, type: :id

    belongs_to :railway_admin, Rms.Accounts.RailwayAdministrator,
      foreign_key: :current_railway_admin,
      type: :id

    belongs_to :log_admin, Rms.Accounts.RailwayAdministrator,
      foreign_key: :log_admin_id,
      type: :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(company_info, attrs) do
    company_info
    |> cast(attrs, [
      :company_name,
      :company_telephone,
      :company_address,
      :company_email,
      :vat,
      :password_expiry_days,
      :login_attempts,
      :status,
      :on_hire_max_period,
      :current_railway_admin,
      :prefered_ccy_id,
      :maker_id,
      :checker_id,
      :unmatched_aging_period,
      :wagon_mvt_status,
      :log_admin_id,
      :free_days
    ])
    |> validate_required([
      :company_name,
      :company_telephone,
      :company_address,
      :company_email,
      :vat,
      :password_expiry_days,
      :login_attempts,
      :on_hire_max_period,
      :current_railway_admin,
      :prefered_ccy_id,
      :log_admin_id,
      :free_days
    ])
  end
end
