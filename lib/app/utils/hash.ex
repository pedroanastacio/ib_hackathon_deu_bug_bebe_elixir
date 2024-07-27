defmodule App.Utils.Hash do
  def generate_hash(sender, receiver, amount, created_at, currency, public_key) do
    private_key = Application.get_env(:deu_bug_bebe_elixir_ng, App.Repo)[:private_key]
    decoded_private_key = Base.decode16!(private_key)

    data = "#{sender}#{receiver}#{amount}#{created_at}#{currency}#{public_key}"

    signature = sign(decoded_private_key, data)

    key = ExKeccak.hash_256(signature)
    Base.encode16(key)
  end

  def generate_key do
    :crypto.generate_key(:ecdh, :secp256k1)
  end

  def sign(private_key, message) do
    signature =
      :crypto.sign(:ecdsa, :sha256, message, [private_key, :crypto.ec_curve(:secp256k1)])

    signature
  end
end
