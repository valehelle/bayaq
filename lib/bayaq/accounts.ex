defmodule Bayaq.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Bayaq.Repo

  alias Bayaq.Accounts.User
  alias Comeonin.Bcrypt

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User
    |> reverse_order
    |> Repo.all()
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
  def get_user!(id) do
    query = from u in User, 
            where: u.id == ^id,
            preload: [:invoices]
    Repo.one(query)

  end
  def get_user_by_username(username), do: Repo.get_by(User, username: username)
  def get_user_by_email(email), do: Repo.get_by(User, email: email)




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
    |> User.bank_code_changeset(attrs)
    |> Repo.update()
  end

  def update_user_password(%User{} = user, attrs) do
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
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate_user(email, plain_text_password) do
    query = from u in User, where: u.email == ^email
    Repo.one(query)
    |> check_password(plain_text_password)
  end

  defp check_password(nil, _), do: {:error, "Incorrect email or password"}

  defp check_password(user, plain_text_password) do
    case Bcrypt.checkpw(plain_text_password, user.password) do
      true -> {:ok, user}
      false -> {:error, "Incorrect email or password"}
    end
  end




  alias Bayaq.Accounts.Bill

  

  @doc """
  Returns the list of bills.

  ## Examples

      iex> list_bills()
      [%Bill{}, ...]

  """
  def list_bills do
    query = from b in Bill,
           preload: [:user] 

    query
    |> reverse_order
    |> Repo.all()
  end

  @doc """
  Gets a single bill.

  Raises `Ecto.NoResultsError` if the Bill does not exist.

  ## Examples

      iex> get_bill!(123)
      %Bill{}

      iex> get_bill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bill!(id), do: Repo.get!(Bill, id)

  @doc """
  Creates a bill.

  ## Examples

      iex> create_bill(%{field: value})
      {:ok, %Bill{}}

      iex> create_bill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bill(attrs \\ %{}) do
    %Bill{}
    |> Bill.changeset(attrs)
    |> Repo.insert()
  end

  def get_bills(user_id) do
    query = from b in Bill, 
            where: b.user_id == ^user_id,
            order_by: b.id
    Repo.all(query)
  end

  @doc """
  Updates a bill.

  ## Examples

      iex> update_bill(bill, %{field: new_value})
      {:ok, %Bill{}}

      iex> update_bill(bill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bill(%Bill{} = bill, attrs) do
    bill
    |> Bill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Bill.

  ## Examples

      iex> delete_bill(bill)
      {:ok, %Bill{}}

      iex> delete_bill(bill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bill(%Bill{} = bill) do
    Repo.delete(bill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bill changes.

  ## Examples

      iex> change_bill(bill)
      %Ecto.Changeset{source: %Bill{}}

  """
  def change_bill(%Bill{} = bill) do
    Bill.changeset(bill, %{})
  end

  alias Bayaq.Accounts.Reset

  @doc """
  Returns the list of resets.

  ## Examples

      iex> list_resets()
      [%Reset{}, ...]

  """

    def get_user_by_token(token) do 
    query = from r in Reset, 
            where: r.token == ^token,
            where: r.has_expired == false

    Repo.one(query)
    case Repo.one(query) do
      nil -> {:error}
      reset -> 
      user = get_user!(reset.user_id)
      {:ok, user}
    end
  end

  
  def list_resets do
    Repo.all(Reset)
  end

  def invalidate_reset(user_id) do
    query = from r in Reset, 
            where: r.user_id == ^user_id
    resets = Repo.all(query)
    for reset <- resets do
      update_reset(reset, %{has_expired: true})
    end
  end

  @doc """
  Gets a single reset.

  Raises `Ecto.NoResultsError` if the Reset does not exist.

  ## Examples

      iex> get_reset!(123)
      %Reset{}

      iex> get_reset!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reset!(id), do: Repo.get!(Reset, id)

  @doc """
  Creates a reset.

  ## Examples

      iex> create_reset(%{field: value})
      {:ok, %Reset{}}

      iex> create_reset(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reset(attrs \\ %{}) do
    %Reset{}
    |> Reset.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reset.

  ## Examples

      iex> update_reset(reset, %{field: new_value})
      {:ok, %Reset{}}

      iex> update_reset(reset, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reset(%Reset{} = reset, attrs) do
    reset
    |> Reset.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Reset.

  ## Examples

      iex> delete_reset(reset)
      {:ok, %Reset{}}

      iex> delete_reset(reset)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reset(%Reset{} = reset) do
    Repo.delete(reset)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reset changes.

  ## Examples

      iex> change_reset(reset)
      %Ecto.Changeset{source: %Reset{}}

  """
  def change_reset(%Reset{} = reset) do
    Reset.changeset(reset, %{})
  end
end
