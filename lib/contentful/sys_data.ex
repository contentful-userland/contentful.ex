defmodule Contentful.SysData do
  @moduledoc """
  The SysData represents internal additional data for Contetnful API objects, usually found in the
  "sys" part of the response objects. It's also referred to as "common properties".

  See the [official documentation for more information](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/locales).
  """
  defstruct [:id, :revision, :version]

  @type t :: %Contentful.SysData{
          id: String.t(),
          revision: integer() | nil,
          version: integer() | nil
        }
end
