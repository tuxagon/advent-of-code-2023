defmodule Advent2023.Day6 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&calculate_winnable_races/1)
    |> Enum.product()
  end

  def part2(input) do
    input
    |> parse_input()
    |> correct_input()
    |> calculate_winnable_races()
  end

  defp calculate_winnable_races({milliseconds, millimeters}) do
    1..milliseconds
    |> Enum.map(fn charge_time ->
      {charge_time, charge_time * (milliseconds - charge_time)}
    end)
    |> Enum.filter(fn {_, distance} ->
      distance > millimeters
    end)
    |> Enum.count()
  end

  defp correct_input(inputs) do
    inputs
    |> Enum.reduce({"", ""}, fn {t, d}, {ts, ds} ->
      {ts <> "#{t}", ds <> "#{d}"}
    end)
    |> then(fn {ts, ds} ->
      {String.to_integer(ts), String.to_integer(ds)}
    end)
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.filter(fn val -> Integer.parse(val) != :error end)
      |> Enum.map(&String.to_integer/1)
    end)
    |> then(&Enum.zip/1)
  end
end
