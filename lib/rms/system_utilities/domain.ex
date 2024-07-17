defmodule Rms.SystemUtilities.Domain do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]

  schema "tbl_domain" do
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"
    # field :maker_id, :id
    # field :checker_id, :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(domain, attrs) do
    domain
    |> cast(attrs, [:code, :description, :status, :maker_id, :checker_id])
    |> validate_required([:description, :status])
    |> unique_constraint(:code, name: :unique_domain_code, message: "already exists")
  end
end
