defmodule Commodity.Api.Util.Error.InvalidLimitError do
	@moduledoc """
		Application limit exceeded error
	"""
	defexception [plug_status: 429, message: "Limit exceeded"]
end