defmodule App.Utils.Hash do
  def generate_hash(sender, receiver, amount, created_at, currency, public_key) do
    {_, private_key} = generate_key()

    data = "#{sender}#{receiver}#{amount}#{created_at}#{currency}#{public_key}"

    signature = sign(private_key, data)

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
