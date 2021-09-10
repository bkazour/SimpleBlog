defmodule SimpleBlog.Reactions.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reactions" do
    field :type, :integer
    field :comment_id, :id

    timestamps()
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:type, :comment_id])
    |> validate_required([:type, :comment_id])
  end
end
