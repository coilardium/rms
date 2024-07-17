defmodule Rms.SystemUtilities.FileUploadError do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_upload_file_errors" do
    field :col_index, :string
    field :error_msg, :string
    field :filename, :string
    field :new_filename, :string
    field :upload_date, :date
    field :type, :string
    # add :upload_user_id, references(:tbl_users, on_delete: :nothing)

    belongs_to :maker, Rms.Accounts.User, foreign_key: :user_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(file_upload_error, attrs) do
    file_upload_error
    |> cast(attrs, [
      :col_index,
      :error_msg,
      :filename,
      :user_id,
      :new_filename,
      :upload_date,
      :type
    ])

    # |> validate_required([:col_index, :error_msg, :filename])
  end
end
