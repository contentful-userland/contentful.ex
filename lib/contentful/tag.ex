defmodule Contentful.Tag do
  defstruct [:sys]

  @type t :: %Contentful.Tag{
          sys: %Contentful.SysData{}
        }
end
