defmodule Rms.Activity do
  @moduledoc """
  The Activity context.
  """

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Activity.Sys_exception

  @doc """
  Returns the list of tbl_sys_exception.
  
  ## Examples
  
      iex> list_tbl_sys_exception()
      [%Sys_exception{}, ...]
  
  """
  def list_tbl_sys_exception do
    Repo.all(Sys_exception)
  end

  @doc """
  Gets a single sys_exception.
  
  Raises `Ecto.NoResultsError` if the Sys exception does not exist.
  
  ## Examples
  
      iex> get_sys_exception!(123)
      %Sys_exception{}
  
      iex> get_sys_exception!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_sys_exception!(id), do: Repo.get!(Sys_exception, id)

  @doc """
  Creates a sys_exception.
  
  ## Examples
  
      iex> create_sys_exception(%{field: value})
      {:ok, %Sys_exception{}}
  
      iex> create_sys_exception(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_sys_exception(attrs \\ %{}) do
    %Sys_exception{}
    |> Sys_exception.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sys_exception.
  
  ## Examples
  
      iex> update_sys_exception(sys_exception, %{field: new_value})
      {:ok, %Sys_exception{}}
  
      iex> update_sys_exception(sys_exception, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_sys_exception(%Sys_exception{} = sys_exception, attrs) do
    sys_exception
    |> Sys_exception.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sys_exception.
  
  ## Examples
  
      iex> delete_sys_exception(sys_exception)
      {:ok, %Sys_exception{}}
  
      iex> delete_sys_exception(sys_exception)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_sys_exception(%Sys_exception{} = sys_exception) do
    Repo.delete(sys_exception)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sys_exception changes.
  
  ## Examples
  
      iex> change_sys_exception(sys_exception)
      %Ecto.Changeset{data: %Sys_exception{}}
  
  """
  def change_sys_exception(%Sys_exception{} = sys_exception, attrs \\ %{}) do
    Sys_exception.changeset(sys_exception, attrs)
  end

  alias Rms.Activity.UserLog

  @doc """
  Returns the list of tbl_user_activity.
  
  ## Examples
  
      iex> list_tbl_user_activity()
      [%UserLog{}, ...]
  
  """
  def list_tbl_user_activity do
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
