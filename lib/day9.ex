defmodule Advent2023.Day9 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&extrapolate/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&extrapolate_backwards/1)
    |> Enum.sum()
  end

  defp extrapolate([a | rest]) do
    rest
    |> Enum.reduce({a, []}, fn next, {prev, diffs} ->
      {next, [next - prev | diffs]}
    end)
    |> then(fn {last, next_sequence_reversed} ->
      if all_zeroes?(next_sequence_reversed) do
        last
      else
        last + extrapolate(Enum.reverse(next_sequence_reversed))
      end
    end)
  end

  defp extrapolate_backwards(sequence) do
    [a | rest] = Enum.reverse(sequence)

    rest
    |> Enum.reduce({a, []}, fn next, {prev, diffs} ->
      {next, [prev - next | diffs]}
    end)
    |> then(fn {last, next_sequence} ->
      if all_zeroes?(next_sequence) do
        last
      else
        last - extrapolate_backwards(next_sequence)
      end
    end)
  end

  defp all_zeroes?(sequence), do: Enum.all?(sequence, &(&1 == 0))

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
