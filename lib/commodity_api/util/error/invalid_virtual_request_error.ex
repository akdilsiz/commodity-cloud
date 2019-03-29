defmodule Commodity.Api.Util.InvalidVirtualRequestError do
  defexception [plug_status: 400, message: "Parameters error"]
end