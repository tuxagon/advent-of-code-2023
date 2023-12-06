defmodule Advent2023 do
  alias Advent2023.{Day1, Day2, Day3, Day4, Day5}

  def run(day, suffix \\ "") do
    input = read_input(day, suffix)

    case day_module(day) do
      nil -> nil
      module -> {module.part1(input), module.part2(input)}
    end
  end

  defp day_module(1), do: Day1
  defp day_module(2), do: Day2
  defp day_module(3), do: Day3
  defp day_module(4), do: Day4
  defp day_module(5), do: Day5
  defp day_module(_), do: nil

  defp read_input(day, suffix) do
    File.read!("input/day#{day}#{suffix}.txt")
  end
end
