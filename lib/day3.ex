defmodule Advent2023.Day3 do
  defmodule Schematic do
    defstruct [:parts, :symbols]
  end

  defmodule Part do
    defstruct [:number, :locations]
  end

  def part1(input) do
    input
    |> parse_schematic()
    |> adjacent_part_numbers()
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_schematic()
    |> gear_ratios()
    |> Enum.sum()
  end

  defp adjacent_part_numbers(%Schematic{} = schematic) do
    schematic
    |> valid_part_number_locations()
    |> Enum.flat_map(&parts_for_location(&1, schematic))
    |> Enum.uniq()
    |> Enum.map(fn %Part{number: number} -> number end)
  end

  defp gear_ratios(%Schematic{} = schematic) do
    schematic
    |> valid_locations_for_possible_gears()
    |> Enum.map(fn locations ->
      locations
      |> Enum.flat_map(&parts_for_location(&1, schematic))
      |> Enum.uniq()
    end)
    |> Enum.filter(fn parts -> Enum.count(parts) == 2 end)
    |> Enum.map(fn [part1, part2] ->
      part1.number * part2.number
    end)
  end

  defp valid_part_number_locations(%Schematic{symbols: symbols}) do
    symbols
    |> Enum.flat_map(fn {_symbol, {row, col}} ->
      Enum.map(adjacency_modifiers(), fn {rm, cm} -> {row + rm, col + cm} end)
    end)
    |> Enum.uniq()
  end

  defp valid_locations_for_possible_gears(%Schematic{symbols: symbols}) do
    symbols
    |> Enum.filter(fn {symbol, _location} -> symbol == "*" end)
    |> Enum.map(fn {_symbol, {row, col}} ->
      Enum.map(adjacency_modifiers(), fn {rm, cm} -> {row + rm, col + cm} end)
    end)
  end

  defp parts_for_location(location, %Schematic{parts: parts}) do
    parts
    |> Enum.filter(fn %Part{locations: locations} ->
      Enum.any?(locations, fn part_location -> location == part_location end)
    end)
  end

  defp adjacency_modifiers(),
    do: [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  defp new_schematic() do
    %Schematic{parts: [], symbols: []}
  end

  defp parse_schematic(text) do
    text
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(new_schematic(), &parse_line/2)
  end

  defp parse_line({line, row}, %Schematic{} = schematic) do
    Regex.scan(~r/(?:\d+|.)/, line)
    |> List.flatten()
    |> Enum.reduce({0, schematic}, fn value, {col, acc} ->
      case value do
        "." ->
          {col + 1, acc}

        symbol_or_number ->
          updated_schematic =
            if String.match?(symbol_or_number, ~r/^\d+$/) do
              insert_part_for_schematic(acc, {row, col}, symbol_or_number)
            else
              insert_symbol_for_schematic(acc, {row, col}, symbol_or_number)
            end

          {col + String.length(symbol_or_number), updated_schematic}
      end
    end)
    |> elem(1)
  end

  defp insert_part_for_schematic(%Schematic{} = schematic, {row, starting_col}, part_number) do
    locations =
      List.duplicate(row, String.length(part_number))
      |> Enum.with_index()
      |> Enum.map(fn {r, i} -> {r, starting_col + i} end)

    Map.update!(schematic, :parts, fn parts ->
      [%Part{number: String.to_integer(part_number), locations: locations} | parts]
    end)
  end

  defp insert_symbol_for_schematic(%Schematic{} = schematic, location, symbol) do
    Map.update!(schematic, :symbols, fn symbols ->
      [{symbol, location} | symbols]
    end)
  end
end
