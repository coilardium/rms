defmodule Rms.Accounts do
  @moduledoc """
  def  do
  The Accounts context.
  """

  # Rms.Accounts.search_client("g", 0)

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Accounts.User

  @doc """
  Returns the list of tbl_users.
  
  ## Examples
  
      iex> list_tbl_users()
      [%User{}, ...]
  
  """
  def list_tbl_users do
    User
    |> preload([:role, :checker, :maker, :user_region, :station])
    |> Repo.all()
  end

  def search_user(search_term, start) do
    User
    |> where(
      [u],
      fragment("lower(concat(?, '  ', ?)) like lower(?)", u.first_name, u.last_name, ^search_term) and
        u.status == "A"
    )
    |> compose_search_user_query(start)
    |> Repo.all()
  end

  def select_user(search_term, start) do
    User
    |> where(
      [u],
      fragment("lower(concat(?, '  ', ?)) like lower(?)", u.first_name, u.last_name, ^search_term)
    )
    |> compose_search_user_query(start)
    |> Repo.all()
  end

  defp compose_search_user_query(query, start) do
    query
    |> order_by([u], u.id)
    |> group_by([u], [fragment("concat(?, '  ', ?)", u.first_name, u.last_name), u.id])
    |> limit(50)
    |> offset(^start)
    |> select([u], %{
      total_count: fragment("count(*) AS total_count"),
      id: u.id,
      text: fragment("concat(?, '  ', ?)", u.first_name, u.last_name)
    })
  end

  @doc """
  Gets a single user.
  
  Raises `Ecto.NoResultsError` if the User does not exist.
  
  ## Examples
  
      iex> get_user!(123)
      %User{}
  
      iex> get_user!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_user!(id), do: Repo.get!(User, id)

  def user_lookup!(id) do
    User
    |> where(id: ^id)
    |> preload([:role, :checker, :maker, :user_region, :station])
    |> Repo.one()
  end

  @doc """
  Creates a user.
  
  ## Examples
  
      iex> create_user(%{field: value})
      {:ok, %User{}}
  
      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  
  ## Examples
  
      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}
  
      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  
  ## Examples
  
      iex> delete_user(user)
      {:ok, %User{}}
  
      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  
  ## Examples
  
      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}
  
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Rms.Accounts.UserRole

  @doc """
  Returns the list of tbl_user_role.
  
  ## Examples
  
      iex> list_tbl_user_role()
      [%UserRole{}, ...]
  
  """
  def list_tbl_user_role do
    UserRole |> preload([:maker, :checker]) |> Repo.all()
  end

  def list_roles do
    UserRole |> preload([:maker, :checker]) |> Repo.all()
  end

  @doc """
  Gets a single user_role.
  
  Raises `Ecto.NoResultsError` if the User role does not exist.
  
  ## Examples
  
      iex> get_user_role!(123)
      %UserRole{}
  
      iex> get_user_role!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_user_role!(id), do: Repo.get!(UserRole, id)

  @doc """
  Creates a user_role.
  
  ## Examples
  
      iex> create_user_role(%{field: value})
      {:ok, %UserRole{}}
  
      iex> create_user_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_user_role(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_role.
  
  ## Examples
  
      iex> update_user_role(user_role, %{field: new_value})
      {:ok, %UserRole{}}
  
      iex> update_user_role(user_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_user_role(%UserRole{} = user_role, attrs) do
    user_role
    |> UserRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_role.
  
  ## Examples
  
      iex> delete_user_role(user_role)
      {:ok, %UserRole{}}
  
      iex> delete_user_role(user_role)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_user_role(%UserRole{} = user_role) do
    Repo.delete(user_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_role changes.
  
  ## Examples
  
      iex> change_user_role(user_role)
      %Ecto.Changeset{data: %UserRole{}}
  
  """
  def change_user_role(%UserRole{} = user_role, attrs \\ %{}) do
    UserRole.changeset(user_role, attrs)
  end

  alias Rms.Accounts.LocoDriver

  @doc """
  Returns the list of tbl_loco_driver.
  
  ## Examples
  
      iex> list_tbl_loco_driver()
      [%LocoDriver{}, ...]
  
  """
  def get_loco_driver_data do
    User
    # |> join(:left, [u], l in "tbl_loco_driver", on: u.id == l.user_id)
    |> join(:left, [u], l in Rms.Accounts.LocoDriver, on:  u.id == l.user_id)
    |> select([u, l], %{
      id: u.id,
      first_name: u.first_name,
      last_name: u.last_name
    })
    |> Repo.all()
  end

  def list_tbl_loco_driver do
    LocoDriver
    |> preload([:user, :checker, :maker])
    |> Repo.all()
  end

  def get_loco_drivers do
    LocoDriver
    |> join(:left, [u], l in User, on: u.user_id == l.id)
    |> select([u, l], %{
      id: l.id,
      first_name: l.first_name,
      last_name: l.last_name
    })
    |> Repo.all()
  end

  @doc """
  Gets a single loco_driver.
  
  Raises `Ecto.NoResultsError` if the Loco driver does not exist.
  
  ## Examples
  
      iex> get_loco_driver!(123)
      %LocoDriver{}
  
      iex> get_loco_driver!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_loco_driver!(id), do: Repo.get!(LocoDriver, id)

  @doc """
  Creates a loco_driver.
  
  ## Examples
  
      iex> create_loco_driver(%{field: value})
      {:ok, %LocoDriver{}}
  
      iex> create_loco_driver(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_loco_driver(attrs \\ %{}) do
    %LocoDriver{}
    |> LocoDriver.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a loco_driver.
  
  ## Examples
  
      iex> update_loco_driver(loco_driver, %{field: new_value})
      {:ok, %LocoDriver{}}
  
      iex> update_loco_driver(loco_driver, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_loco_driver(%LocoDriver{} = loco_driver, attrs) do
    loco_driver
    |> LocoDriver.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a loco_driver.
  
  ## Examples
  
      iex> delete_loco_driver(loco_driver)
      {:ok, %LocoDriver{}}
  
      iex> delete_loco_driver(loco_driver)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_loco_driver(%LocoDriver{} = loco_driver) do
    Repo.delete(loco_driver)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking loco_driver changes.
  
  ## Examples
  
      iex> change_loco_driver(loco_driver)
      %Ecto.Changeset{data: %LocoDriver{}}
  
  """
  def change_loco_driver(%LocoDriver{} = loco_driver, attrs \\ %{}) do
    LocoDriver.changeset(loco_driver, attrs)
  end

  alias Rms.Accounts.Clients

  @doc """
  Returns the list of tbl_clients.
  
  ## Examples
  
      iex> list_tbl_clients()
      [%Clients{}, ...]
  
  """
  def list_tbl_clients do
    Clients
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  def search_client(search_term, start) do
    Clients
    |> where(
      [c],
      fragment("lower(?) like lower(?)", c.client_name, ^search_term) and c.status == "A"
    )
    |> compose_search_client_query(start)
    |> Repo.all()
  end

  def select_client(search_term, start) do
    Clients
    |> where([c], fragment("lower(?) like lower(?)", c.client_name, ^search_term))
    |> compose_search_client_query(start)
    |> Repo.all()
  end

  defp compose_search_client_query(query, start) do
    query
    |> order_by([c], c.id)
    |> group_by([c], [c.client_name, c.id])
    |> limit(50)
    |> offset(^start)
    |> select([c], %{
      total_count: fragment("count(*) AS total_count"),
      id: c.id,
      text: c.client_name
    })
  end

  # def customer_details do
  #   Repo.all(from x in Clients and c in TariffLines, where: x.client_name == c.client)
  #  end

  #   query = from u in "users",
  #           where: u.age > 18,
  #           select: u.name

  # # Send the query to the repository
  # Repo.all(query)

  @doc """
  Gets a single clients.
  
  Raises `Ecto.NoResultsError` if the Clients does not exist.
  
  ## Examples
  
      iex> get_clients!(123)
      %Clients{}
  
      iex> get_clients!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_clients!(id), do: Repo.get!(Clients, id)

  @doc """
  Creates a clients.
  
  ## Examples
  
      iex> create_clients(%{field: value})
      {:ok, %Clients{}}
  
      iex> create_clients(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_clients(attrs \\ %{}) do
    %Clients{}
    |> Clients.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a clients.
  
  ## Examples
  
      iex> update_clients(clients, %{field: new_value})
      {:ok, %Clients{}}
  
      iex> update_clients(clients, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_clients(%Clients{} = clients, attrs) do
    clients
    |> Clients.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a clients.
  
  ## Examples
  
      iex> delete_clients(clients)
      {:ok, %Clients{}}
  
      iex> delete_clients(clients)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_clients(%Clients{} = clients) do
    Repo.delete(clients)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking clients changes.
  
  ## Examples
  
      iex> change_clients(clients)
      %Ecto.Changeset{data: %Clients{}}
  
  """
  def change_clients(%Clients{} = clients, attrs \\ %{}) do
    Clients.changeset(clients, attrs)
  end

  alias Rms.Accounts.RailwayAdministrator

  @doc """
  Returns the list of tbl_railway_administrator.
  
  ## Examples
  
      iex> list_tbl_railway_administrator()
      [%RailwayAdministrator{}, ...]
  
  """

  # def list_tbl_railway_administrator do
  #   Repo.all(RailwayAdministrator)
  # end

  def list_tbl_railway_administrator do
    RailwayAdministrator
    |> preload([:maker, :checker, :country])
    |> Repo.all()
  end

  @doc """
  Gets a single railway_administrator.
  
  Raises `Ecto.NoResultsError` if the Railway administrator does not exist.
  
  ## Examples
  
      iex> get_railway_administrator!(123)
      %RailwayAdministrator{}
  
      iex> get_railway_administrator!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_railway_administrator!(id), do: Repo.get!(RailwayAdministrator, id)

  @doc """
  Creates a railway_administrator.
  
  ## Examples
  
      iex> create_railway_administrator(%{field: value})
      {:ok, %RailwayAdministrator{}}
  
      iex> create_railway_administrator(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_railway_administrator(attrs \\ %{}) do
    %RailwayAdministrator{}
    |> RailwayAdministrator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a railway_administrator.
  
  ## Examples
  
      iex> update_railway_administrator(railway_administrator, %{field: new_value})
      {:ok, %RailwayAdministrator{}}
  
      iex> update_railway_administrator(railway_administrator, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_railway_administrator(%RailwayAdministrator{} = railway_administrator, attrs) do
    railway_administrator
    |> RailwayAdministrator.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a railway_administrator.
  
  ## Examples
  
      iex> delete_railway_administrator(railway_administrator)
      {:ok, %RailwayAdministrator{}}
  
      iex> delete_railway_administrator(railway_administrator)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_railway_administrator(%RailwayAdministrator{} = railway_administrator) do
    Repo.delete(railway_administrator)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking railway_administrator changes.
  
  ## Examples
  
      iex> change_railway_administrator(railway_administrator)
      %Ecto.Changeset{data: %RailwayAdministrator{}}
  
  """
  def change_railway_administrator(%RailwayAdministrator{} = railway_administrator, attrs \\ %{}) do
    RailwayAdministrator.changeset(railway_administrator, attrs)
  end

  alias Rms.Accounts.UserRegion

  @doc """
  Returns the list of tbl_user_region.
  
  ## Examples
  
      iex> list_tbl_user_region()
      [%UserRegion{}, ...]
  
  """
  def list_tbl_user_region do
    UserRegion
    |> preload([:maker, :checker, :station])
    |> Repo.all()
  end

  @doc """
  Gets a single user_region.
  
  Raises `Ecto.NoResultsError` if the User region does not exist.
  
  ## Examples
  
      iex> get_user_region!(123)
      %UserRegion{}
  
      iex> get_user_region!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_user_region!(id), do: Repo.get!(UserRegion, id)

  @doc """
  Creates a user_region.
  
  ## Examples
  
      iex> create_user_region(%{field: value})
      {:ok, %UserRegion{}}
  
      iex> create_user_region(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_user_region(attrs \\ %{}) do
    %UserRegion{}
    |> UserRegion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_region.
  
  ## Examples
  
      iex> update_user_region(user_region, %{field: new_value})
      {:ok, %UserRegion{}}
  
      iex> update_user_region(user_region, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_user_region(%UserRegion{} = user_region, attrs) do
    user_region
    |> UserRegion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_region.
  
  ## Examples
  
      iex> delete_user_region(user_region)
      {:ok, %UserRegion{}}
  
      iex> delete_user_region(user_region)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_user_region(%UserRegion{} = user_region) do
    Repo.delete(user_region)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_region changes.
  
  ## Examples
  
      iex> change_user_region(user_region)
      %Ecto.Changeset{data: %UserRegion{}}
  
  """
  def change_user_region(%UserRegion{} = user_region, attrs \\ %{}) do
    UserRegion.changeset(user_region, attrs)
  end
end
