defmodule Rms.NotificationsTest do
  use Rms.DataCase

  alias Rms.Notifications

  describe "tbl_email_alerts" do
    alias Rms.Notifications.Email

    @valid_attrs %{email: "some email", status: "some status", type: "some type"}
    @update_attrs %{
      email: "some updated email",
      status: "some updated status",
      type: "some updated type"
    }
    @invalid_attrs %{email: nil, status: nil, type: nil}

    def email_fixture(attrs \\ %{}) do
      {:ok, email} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_email()

      email
    end

    test "list_tbl_email_alerts/0 returns all tbl_email_alerts" do
      email = email_fixture()
      assert Notifications.list_tbl_email_alerts() == [email]
    end

    test "get_email!/1 returns the email with given id" do
      email = email_fixture()
      assert Notifications.get_email!(email.id) == email
    end

    test "create_email/1 with valid data creates a email" do
      assert {:ok, %Email{} = email} = Notifications.create_email(@valid_attrs)
      assert email.email == "some email"
      assert email.status == "some status"
      assert email.type == "some type"
    end

    test "create_email/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_email(@invalid_attrs)
    end

    test "update_email/2 with valid data updates the email" do
      email = email_fixture()
      assert {:ok, %Email{} = email} = Notifications.update_email(email, @update_attrs)
      assert email.email == "some updated email"
      assert email.status == "some updated status"
      assert email.type == "some updated type"
    end

    test "update_email/2 with invalid data returns error changeset" do
      email = email_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_email(email, @invalid_attrs)
      assert email == Notifications.get_email!(email.id)
    end

    test "delete_email/1 deletes the email" do
      email = email_fixture()
      assert {:ok, %Email{}} = Notifications.delete_email(email)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_email!(email.id) end
    end

    test "change_email/1 returns a email changeset" do
      email = email_fixture()
      assert %Ecto.Changeset{} = Notifications.change_email(email)
    end
  end
end
