defmodule HEBornMigration.Web.AccountTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Web.Account

  alias HEBornMigration.Factory

  @moduletag :unit

  describe "create/4" do
    test "succeeds with valid fields" do
      claim = Factory.build(:claim)

      email = "valid@email.com"
      password = "validpassword"

      cs = Account.create(claim, email, password, password)
      assert cs.valid?
    end

    test "adds token error when called with nil claim" do
      email = "valid@email.com"
      password = "validpassword"

      cs =  Account.create(nil, email, password, password)
      assert :token in Keyword.keys(cs.errors)
    end

    test "validate fields" do
      claim = Factory.build(:claim)

      # REVIEW: maybe use a random data generator for invalid params
      short_password = "v"
      invalid_email = "invalid.email"

      cs = Account.create(claim, invalid_email, short_password, short_password)
      assert :password in Keyword.keys(cs.errors)
      assert :email in Keyword.keys(cs.errors)
      refute cs.valid?

      # FIXME: add password_confirmation validation test
    end
  end

  describe "confirm/1" do
    test "confirms the account" do
      account = Factory.build(:account)
      cs = Account.confirm(account)

      refute account.confirmed
      assert {:ok, true} == Ecto.Changeset.fetch_change(cs, :confirmed)
    end
  end
end
