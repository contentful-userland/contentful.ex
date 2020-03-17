defmodule Contentful.Collection do
  @callback fetch_all(Space.t(), list(keyword()), String.t(), String.t() | nil) ::
              {:ok, list(struct())}
              | {:error, atom(), original_message: String.t()}
              | {:error, :unknown}
  @callback fetch_one(
              Space.t() | String.t(),
              String.t(),
              String.t(),
              String.t() | nil
            ) ::
              {:ok, struct()}
              | {:error, atom(), original_message: String.t()}
              | {:error, :unknown}
end
