defmodule Advent2023 do
  alias Advent2023.{Day1, Day2, Day3, Day4}

  def run(day) do
    input = read_input(day)
    run_day(day, input)
  end

  defp run_day(1, input), do: {Day1.part1(input), Day1.part2(input)}
  defp run_day(2, input), do: {Day2.part1(input), Day2.part2(input)}
  defp run_day(3, input), do: {Day3.part1(input), Day3.part2(input)}
  defp run_day(4, input), do: {Day4.part1(input), Day4.part2(input)}
  defp run_day(_, _), do: nil

  defp read_input(day) do
    File.read!("input/day#{day}.txt")
  end
end
