defmodule BlogPlatform.Users.User do

  use Ecto.Schema
  import Ecto.Changeset
  alias BlogPlatform.Posts.Post


  @fields ~w/role/a
  @required_fields ~w/first_name last_name user_name password password_confirmation email/a
  @role_values ~w/USER ADMIN/a
  @allowed_role_values ~w/USER ADMIN/a

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :user_name, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :email, :string
    field :role, Ecto.Enum, values: @role_values, default: :USER
    has_many :posts, Post
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:password, min: 6, max: 100)
    |> validate_password_confirmation()
    |> put_password_hash()
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> validate_role()
  end



  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset


  defp validate_password_confirmation(changeset) do
    password = get_field(changeset, :password)
    password_confirmation = get_field(changeset, :password_confirmation)

    if password_confirmation === password do
      changeset
    else
      add_error(changeset, :password_confirmation, "the password_confirmation should be like password")
    end
  end

  defp validate_role(changeset) do
    role = get_field(changeset, :role)

    if role in @allowed_role_values do
      changeset
    else
      add_error(changeset, :role, "can't use this role while use this api for registers")
    end
  end

end
