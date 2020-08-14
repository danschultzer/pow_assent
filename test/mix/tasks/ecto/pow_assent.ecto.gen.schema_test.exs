defmodule Mix.Tasks.PowAssent.Ecto.Gen.SchemaTest do
  use PowAssent.Test.Mix.TestCase

  alias Mix.Tasks.PowAssent.Ecto.Gen.Schema

  @tmp_path      Path.join(["tmp", inspect(Schema)])
  @expected_file Path.join(["lib", "pow_assent", "users", "user_identity.ex"])

  setup do
    File.rm_rf!(@tmp_path)
    File.mkdir_p!(@tmp_path)

    :ok
  end

  test "generates schema file" do
    File.cd!(@tmp_path, fn ->
      Schema.run([])

      assert File.exists?(@expected_file)

      content = File.read!(@expected_file)

      assert content =~ "defmodule PowAssent.Users.UserIdentity do"
      assert content =~ "user: PowAssent.Users.User"
      assert content =~ "timestamps()"
    end)
  end

  test "generates with :binary_id" do
    options = ~w(--binary-id)

    File.cd!(@tmp_path, fn ->
      Schema.run(options)

      assert File.exists?(@expected_file)

      file = File.read!(@expected_file)

      assert file =~ "@primary_key {:id, :binary_id, autogenerate: true}"
      assert file =~ "@foreign_key_type :binary_id"
    end)
  end

  test "doesn't make duplicate files" do
    File.cd!(@tmp_path, fn ->
      Schema.run([])

      assert_raise Mix.Error, "schema file can't be created, there is already a schema file in lib/pow_assent/users/user_identity.ex.", fn ->
        Schema.run([])
      end
    end)
  end
end
