defmodule Commodity.Api.Util.InvalidVirtualRequestChangesetError do
  defexception [:changeset, plug_status: 400, message: "invalid request parameters"]

  def message(%{changeset: changeset}) do
    Ecto.InvalidChangesetError.message(%{action: :submission,
                                          changeset: changeset})
  end
end