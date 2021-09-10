defmodule SimpleBlog.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  alias SimpleBlog.Reactions.Reaction
  alias SimpleBlog.Comments

  schema "comments" do
    field :content, :string
    field :name, :string
    field :post_id, :id
    has_many :reactions, Reaction

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:name, :content, :post_id])
    |> validate_required([:name, :content, :post_id])
  end

end
