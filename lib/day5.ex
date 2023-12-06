defmodule Advent2023.Day5 do
  defmodule Almanac do
    defstruct [:seeds, :map]
  end

  def part1(input) do
    input
    |> String.split("\n\n")
    |> Enum.reduce(new_almanac(), &parse_section/2)
    |> find_locations_for_seeds()
    |> Enum.min()
  end

  def part2(input) do
    input
    |> String.split("\n\n")
    |> Enum.reduce(new_almanac(), &parse_section/2)
    |> find_location_for_seed_ranges()
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  defp new_almanac do
    %Almanac{seeds: [], map: %{}}
  end

  defp find_locations_for_seeds(almanac) do
    almanac.seeds
    |> Enum.map(fn seed ->
      traverse_almanac(almanac, :seed, seed, [
        :soil,
        :fertilizer,
        :water,
        :light,
        :temperature,
        :humidity,
        :location
      ])
    end)
  end

  defp find_location_for_seed_ranges(almanac) do
    almanac.seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, range_length] -> {start, start + range_length - 1} end)
    |> Enum.flat_map(fn seed_range ->
      process_seed_through_maps(seed_range, almanac.map)
    end)
  end

  defp process_seed_through_maps(seed_range, maps) do
    map_sequence = [
      {:seed, :soil},
      {:soil, :fertilizer},
      {:fertilizer, :water},
      {:water, :light},
      {:light, :temperature},
      {:temperature, :humidity},
      {:humidity, :location}
    ]

    map_sequence
    |> Enum.reduce([seed_range], fn key, acc ->
      maps = Map.get(maps, key)

      Enum.flat_map(maps, fn map ->
        process_ranges(acc, map)
      end)
    end)
  end

  defp process_ranges(ranges, {destination_start, source_start, range_length}) do
    Enum.reduce(ranges, [], fn {range_start, range_end}, acc ->
      source_end = source_start + range_length - 1

      case add_if_within_range(
             acc,
             {range_start, range_end},
             {source_start, source_end},
             destination_start
           ) do
        [] -> [{range_start, range_end}]
        new_ranges -> new_ranges
      end
    end)
  end

  defp add_if_within_range(
         acc,
         {range_start, range_end},
         {source_start, source_end},
         destination_start
       ) do
    case {range_start <= source_end, range_end >= source_start} do
      {true, true} ->
        within_start = max(range_start, source_start)
        within_end = min(range_end, source_end)
        mapped_start = within_start - source_start + destination_start
        mapped_end = within_end - source_start + destination_start
        [{mapped_start, mapped_end} | acc]

      _ ->
        []
    end
  end

  defp traverse_almanac(almanac, source_type, source_value, path) do
    Enum.reduce(path, {source_type, source_value}, fn destination, {source, number} ->
      ranges = Map.get(almanac.map, {source, destination}, [])
      next_number = find_map_number(ranges, number)
      {destination, next_number}
    end)
    |> elem(1)
  end

  defp find_map_number([], number), do: number

  defp find_map_number([{dest_start, source_start, range_length} | ranges], number) do
    if number in source_start..(source_start + range_length - 1) do
      dest_start + (number - source_start)
    else
      find_map_number(ranges, number)
    end
  end

  defp parse_section("seeds:" <> seed_text, almanac) do
    seeds =
      seed_text
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    Map.put(almanac, :seeds, seeds)
  end

  defp parse_section(section_text, almanac) do
    {source, destination, map_text} = parse_map_header(section_text)

    map_text
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn line, acc ->
      [
        line
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
        | acc
      ]
    end)
    |> then(fn maps ->
      Map.put(almanac, :map, Enum.into(almanac.map, %{{source, destination} => maps}))
    end)
  end

  def parse_map_header(text) do
    case text do
      "seed-to-soil map:" <> map_text -> {:seed, :soil, map_text}
      "soil-to-fertilizer map:" <> map_text -> {:soil, :fertilizer, map_text}
      "fertilizer-to-water map:" <> map_text -> {:fertilizer, :water, map_text}
      "water-to-light map:" <> map_text -> {:water, :light, map_text}
      "light-to-temperature map:" <> map_text -> {:light, :temperature, map_text}
      "temperature-to-humidity map:" <> map_text -> {:temperature, :humidity, map_text}
      "humidity-to-location map:" <> map_text -> {:humidity, :location, map_text}
      _ -> {:unknown, :unknown, ""}
    end
  end
end
