defmodule Rms.Logs do
  @moduledoc """
  The Logs context.
  """
  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Logs.UserLog

  @doc """
  Returns the list of tbl_user_log.
  
  ## Examples
  
      iex> list_tbl_user_log()
      [%UserLog{}, ...]
  
  """
  def list_tbl_user_log do
    Repo.all(UserLog)
  end

  @doc """
  Gets a single user_log.
  
  Raises `Ecto.NoResultsError` if the User log does not exist.
  
  ## Examples
  
      iex> get_user_log!(123)
      %UserLog{}
  
      iex> get_user_log!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_user_log!(id), do: Repo.get!(UserLog, id)

  @doc """
  Creates a user_log.
  
  ## Examples
  
      iex> create_user_log(%{field: value})
      {:ok, %UserLog{}}
  
      iex> create_user_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_user_log(attrs \\ %{}) do
    %UserLog{}
    |> UserLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_log.
  
  ## Examples
  
      iex> update_user_log(user_log, %{field: new_value})
      {:ok, %UserLog{}}
  
      iex> update_user_log(user_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_user_log(%UserLog{} = user_log, attrs) do
    user_log
    |> UserLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_log.
  
  ## Examples
  
      iex> delete_user_log(user_log)
      {:ok, %UserLog{}}
  
      iex> delete_user_log(user_log)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_user_log(%UserLog{} = user_log) do
    Repo.delete(user_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_log changes.
  
  ## Examples
  
      iex> change_user_log(user_log)
      %Ecto.Changeset{data: %UserLog{}}
  
  """
  def change_user_log(%UserLog{} = user_log, attrs \\ %{}) do
    UserLog.changeset(user_log, attrs)
  end

  def get_logs_by(user_id) do
    UserLog
    |> preload([:user])
    |> where([u], u.user_id == ^user_id)
    |> select(
      [u],
      map(
        u,
        [
          :id,
          :user_id,
          :inserted_at,
          :activity,
          user: [:first_name, :last_name, :email]
        ]
      )
    )
    |> Repo.all()
  end
end
