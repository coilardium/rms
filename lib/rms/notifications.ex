defmodule Rms.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Notifications.Email

  @doc """
  Returns the list of tbl_email_alerts.
  
  ## Examples
  
      iex> list_tbl_email_alerts()
      [%Email{}, ...]
  
  """
  def list_tbl_email_alerts do
    Email
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single email.
  
  Raises `Ecto.NoResultsError` if the Email does not exist.
  
  ## Examples
  
      iex> get_email!(123)
      %Email{}
  
      iex> get_email!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_email!(id), do: Repo.get!(Email, id)

  @doc """
  Creates a email.
  
  ## Examples
  
      iex> create_email(%{field: value})
      {:ok, %Email{}}
  
      iex> create_email(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_email(attrs \\ %{}) do
    %Email{}
    |> Email.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a email.
  
  ## Examples
  
      iex> update_email(email, %{field: new_value})
      {:ok, %Email{}}
  
      iex> update_email(email, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_email(%Email{} = email, attrs) do
    email
    |> Email.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a email.
  
  ## Examples
  
      iex> delete_email(email)
      {:ok, %Email{}}
  
      iex> delete_email(email)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_email(%Email{} = email) do
    Repo.delete(email)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email changes.
  
  ## Examples
  
      iex> change_email(email)
      %Ecto.Changeset{data: %Email{}}
  
  """
  def change_email(%Email{} = email, attrs \\ %{}) do
    Email.changeset(email, attrs)
  end

  def get_email_by(type) do
    Email
    |> where([a], a.type == ^type and a.status == "A")
    |> Repo.all()
  end
end
