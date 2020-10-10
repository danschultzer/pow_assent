defmodule PowAssent.Operations do
  @moduledoc """
  Operation methods that glues operation calls to context module.

  A custom context module can be used instead of the default
  `PowAssent.Ecto.UserIdentities.Context` if a `:user_identities_context` key
  is passed in the PowAssent configuration.
  """
  alias PowAssent.{Config, Ecto.UserIdentities.Context}
  alias Pow.Config, as: PowConfig

  @doc """
  Retrieve a user with the strategy provider name and uid.

  This calls `Pow.Ecto.UserIdentities.Context.get_user_by_provider_uid/3` or
  `get_user_by_provider_uid/2` on a custom context module.
  """
  @spec get_user_by_provider_uid(binary(), binary(), Config.t()) :: map() | nil | no_return
  def get_user_by_provider_uid(provider, uid, config) do
    case context_module(config) do
      Context -> Context.get_user_by_provider_uid(provider, uid, config)
      module  -> module.get_user_by_provider_uid(provider, uid)
    end
  end

  @doc """
  Upserts user identity for the user, and strategy provider name and uid.

  This calls `Pow.Ecto.UserIdentities.Context.upsert/3` or
  `upsert/2` on a custom context module.
  """
  @spec upsert(map(), map(), Config.t()) :: {:ok, map()} | {:error, {:bound_to_different_user, map()}} | {:error, map()} | no_return
  def upsert(user, user_identity_params, config) do
    case context_module(config) do
      Context -> Context.upsert(user, user_identity_params, config)
      module  -> module.upsert(user, user_identity_params)
    end
  end

  @doc """
  Creates user with user identity with the provided user params.

  This calls `Pow.Ecto.UserIdentities.Context.create_user/4` or
  `create_user/3` on a custom context module.
  """
  @spec create_user(map(), map(), map() | nil, Config.t()) :: {:ok, map()} | {:error, {:bound_to_different_user | :invalid_user_id_field, map()}} | {:error, map()} | no_return
  def create_user(user_identity_params, user_params, user_id_params, config) do
    case context_module(config) do
      Context -> Context.create_user(user_identity_params, user_params, user_id_params, config)
      module  -> module.create_user(user_identity_params, user_params, user_id_params)
    end
  end

  @doc """
  Build a changeset from a blank user struct.

  It'll use the schema module fetched from the config through
  `Pow.Config.user!/1` and call `user_identity_changeset/4` on it.
  """
  @spec user_identity_changeset(map(), map(), map(), Config.t()) :: map() | nil
  def user_identity_changeset(params, user_params, user_id_params, config) do
    user_mod = PowConfig.user!(config)

    user_mod
    |> struct()
    |> user_mod.user_identity_changeset(params, user_params, user_id_params)
  end

  @doc """
  Deletes the user identity for user and strategy provider name.

  This calls `Pow.Ecto.UserIdentities.Context.delete/3` or
  `delete/2` on a custom context module.
  """
  @spec delete(map(), binary(), Config.t()) :: {:ok, {number(), nil}} | {:error, {:no_password, map()}} | no_return
  def delete(user, provider, config) do
    case context_module(config) do
      Context -> Context.delete(user, provider, config)
      module  -> module.delete(user, provider)
    end
  end

  @doc """
  Lists all user identity associations for user.

  This calls `Pow.Ecto.UserIdentities.Context.all/2` or
  `all/1` on a custom context module.
  """
  @spec all(map(), Config.t()) :: [map()] | no_return
  def all(user, config) do
    case context_module(config) do
      Context -> Context.all(user, config)
      module  -> module.all(user)
    end
  end

  defp context_module(config) do
    Config.get(config, :user_identities_context, Context)
  end
end
