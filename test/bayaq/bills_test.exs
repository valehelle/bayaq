defmodule Bayaq.BillsTest do
  use Bayaq.DataCase

  alias Bayaq.Bills

  describe "bills" do
    alias Bayaq.Bills.Bill

    @valid_attrs %{amount: "some amount", bill_id: "some bill_id", biller_code: "some biller_code", ref1: "some ref1"}
    @update_attrs %{amount: "some updated amount", bill_id: "some updated bill_id", biller_code: "some updated biller_code", ref1: "some updated ref1"}
    @invalid_attrs %{amount: nil, bill_id: nil, biller_code: nil, ref1: nil}

    def bill_fixture(attrs \\ %{}) do
      {:ok, bill} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bills.create_bill()

      bill
    end

    test "list_bills/0 returns all bills" do
      bill = bill_fixture()
      assert Bills.list_bills() == [bill]
    end

    test "get_bill!/1 returns the bill with given id" do
      bill = bill_fixture()
      assert Bills.get_bill!(bill.id) == bill
    end

    test "create_bill/1 with valid data creates a bill" do
      assert {:ok, %Bill{} = bill} = Bills.create_bill(@valid_attrs)
      assert bill.amount == "some amount"
      assert bill.bill_id == "some bill_id"
      assert bill.biller_code == "some biller_code"
      assert bill.ref1 == "some ref1"
    end

    test "create_bill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bills.create_bill(@invalid_attrs)
    end

    test "update_bill/2 with valid data updates the bill" do
      bill = bill_fixture()
      assert {:ok, %Bill{} = bill} = Bills.update_bill(bill, @update_attrs)
      assert bill.amount == "some updated amount"
      assert bill.bill_id == "some updated bill_id"
      assert bill.biller_code == "some updated biller_code"
      assert bill.ref1 == "some updated ref1"
    end

    test "update_bill/2 with invalid data returns error changeset" do
      bill = bill_fixture()
      assert {:error, %Ecto.Changeset{}} = Bills.update_bill(bill, @invalid_attrs)
      assert bill == Bills.get_bill!(bill.id)
    end

    test "delete_bill/1 deletes the bill" do
      bill = bill_fixture()
      assert {:ok, %Bill{}} = Bills.delete_bill(bill)
      assert_raise Ecto.NoResultsError, fn -> Bills.get_bill!(bill.id) end
    end

    test "change_bill/1 returns a bill changeset" do
      bill = bill_fixture()
      assert %Ecto.Changeset{} = Bills.change_bill(bill)
    end
  end
end
