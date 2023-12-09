defmodule Advent2023 do
  def run(day, suffix \\ "") do
    input = read_input(day, suffix)

    case day_module(day) do
      nil -> nil
      module -> {module.part1(input), module.part2(input)}
    end
  end

  defp day_module(n) when n in 1..25 do
    case Code.ensure_compiled(Module.concat([Advent2023, "Day#{n}"])) do
      {:module, mod} -> mod
      {:error, _} -> nil
    end
  end

  defp day_module(_), do: nil

  defp read_input(day, suffix) do
    File.read!("input/day#{day}#{suffix}.txt")
  end
end
