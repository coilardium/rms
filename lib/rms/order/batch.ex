defmodule Rms.Order.Batch do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  @primary_key {:id, :integer, autogenerate: false}
  schema "tbl_batch" do
    field :batch_no, :string
    field :batch_type, :string, default: "CONSIGNMENT"
    field :status, :string, default: "O"
    field :trans_date, :string
    field :uuid, :string
    field :doc_seq_no, :string
    # field :current_user_id, :id
    # field :last_user_id, :id
    belongs_to :last_user, Rms.Accounts.User, foreign_key: :last_user_id, type: :id
    belongs_to :current_user, Rms.Accounts.User, foreign_key: :current_user_id, type: :id
    belongs_to :user_region, Rms.Accounts.UserRegion, foreign_key: :user_region_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(batch, attrs) do
    batch
    |> cast(attrs, [
      :trans_date,
      :doc_seq_no,
      :batch_no,
      :status,
      :uuid,
      :batch_type,
      :last_user_id,
      :current_user_id,
      :user_region_id
    ])
    |> validate_required([:trans_date, :status, :batch_type])
  end
end
