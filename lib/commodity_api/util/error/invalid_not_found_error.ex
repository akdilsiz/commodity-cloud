defmodule Commodity.Api.Util.InvalidNotFoundError do
  defexception [plug_status: 404, message: "Not found"]
end
