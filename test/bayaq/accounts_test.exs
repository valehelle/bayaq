defmodule Bayaq.AccountsTest do
  use Bayaq.DataCase

  alias Bayaq.Accounts

  describe "users" do
    alias Bayaq.Accounts.User

    @valid_attrs %{email: "some email", password: "some password"}
    @update_attrs %{email: "some updated email", password: "some updated password"}
    @invalid_attrs %{email: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.password == "some password"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.password == "some updated password"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "bills" do
    alias Bayaq.Accounts.Bill

    @valid_attrs %{amount: 42, biller_code: "some biller_code", company_name: "some company_name", ref1: "some ref1", ref2: "some ref2", type: "some type", user_id: "some user_id"}
    @update_attrs %{amount: 43, biller_code: "some updated biller_code", company_name: "some updated company_name", ref1: "some updated ref1", ref2: "some updated ref2", type: "some updated type", user_id: "some updated user_id"}
    @invalid_attrs %{amount: nil, biller_code: nil, company_name: nil, ref1: nil, ref2: nil, type: nil, user_id: nil}

    def bill_fixture(attrs \\ %{}) do
      {:ok, bill} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_bill()

      bill
    end

    test "list_bills/0 returns all bills" do
      bill = bill_fixture()
      assert Accounts.list_bills() == [bill]
    end

    test "get_bill!/1 returns the bill with given id" do
      bill = bill_fixture()
      assert Accounts.get_bill!(bill.id) == bill
    end

    test "create_bill/1 with valid data creates a bill" do
      assert {:ok, %Bill{} = bill} = Accounts.create_bill(@valid_attrs)
      assert bill.amount == 42
      assert bill.biller_code == "some biller_code"
      assert bill.company_name == "some company_name"
      assert bill.ref1 == "some ref1"
      assert bill.ref2 == "some ref2"
      assert bill.type == "some type"
      assert bill.user_id == "some user_id"
    end

    test "create_bill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_bill(@invalid_attrs)
    end

    test "update_bill/2 with valid data updates the bill" do
      bill = bill_fixture()
      assert {:ok, %Bill{} = bill} = Accounts.update_bill(bill, @update_attrs)
      assert bill.amount == 43
      assert bill.biller_code == "some updated biller_code"
      assert bill.company_name == "some updated company_name"
      assert bill.ref1 == "some updated ref1"
      assert bill.ref2 == "some updated ref2"
      assert bill.type == "some updated type"
      assert bill.user_id == "some updated user_id"
    end

    test "update_bill/2 with invalid data returns error changeset" do
      bill = bill_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_bill(bill, @invalid_attrs)
      assert bill == Accounts.get_bill!(bill.id)
    end

    test "delete_bill/1 deletes the bill" do
      bill = bill_fixture()
      assert {:ok, %Bill{}} = Accounts.delete_bill(bill)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_bill!(bill.id) end
    end

    test "change_bill/1 returns a bill changeset" do
      bill = bill_fixture()
      assert %Ecto.Changeset{} = Accounts.change_bill(bill)
    end
  end
end
