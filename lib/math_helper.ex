defmodule Advent2023.MathHelper do
  def gcd(a, 0), do: a
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))

  def lcm_list([head | tail]), do: Enum.reduce(tail, head, &lcm/2)
end
