defmodule Bayaq.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false
  alias Bayaq.Repo

  alias Bayaq.Invoices.Invoice
  alias Bayaq.Bills
  alias Bayaq.Bills.Bill
  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(%{"stripe_id" => stripe_id, "bills" => bills, "email" => email}) do
    {:ok, invoice} = %Invoice{}
                      |> Invoice.changeset(%{"stripe_id" => stripe_id})
                      |> Repo.insert()

    for bill <- bills do
      bill_changeset =  Bill.changeset(%Bill{}, %{"invoice_id" => invoice.id,"amount" => Map.get(bill, "amount"), "bill_id" => Map.get(bill, "id"), "biller_code" => Map.get(bill, "billerCode"), "ref1" => Map.get(bill, "ref1")})
      {:ok, bill} = Repo.insert(bill_changeset)
    end

    {:ok, invoice}
  end



  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{source: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice) do
    Invoice.changeset(invoice, %{})
  end
end
