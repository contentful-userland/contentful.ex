defmodule Contentful.Collection do
  @moduledoc """
  Describes a Contentful collection, which is usually an API response of type Array.
  """
  @callback fetch_all(Space.t(), list(keyword()), String.t(), String.t() | nil) ::
              {:ok, list(struct())}
              | {:error, atom(), original_message: String.t()}
              | {:error, :rate_limit_exceeded, wait_for: integer()}
              | {:error, :unknown}
  @callback fetch_one(
              Space.t() | String.t(),
              String.t(),
              String.t(),
              String.t() | nil
            ) ::
              {:ok, struct()}
              | {:error, atom(), original_message: String.t()}
              | {:error, :rate_limit_exceeded, wait_for: integer()}
              | {:error, :unknown}
end
