defmodule Commodity.Api.Util.InvalidVirtualChangesetError do
  defexception [:changeset, plug_status: 422, message: "invalid payload"]

  def message(%{changeset: changeset}) do
    Ecto.InvalidChangesetError.message(%{action: :submission,
                                          changeset: changeset})
  end
end
