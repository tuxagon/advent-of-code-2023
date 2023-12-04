defmodule Advent2023.Day2 do
  defmodule Game do
    defstruct [:id, :sets]
  end

  def part1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&build_games/1)
    |> Enum.filter(&game_possible?(&1, [{:red, 12}, {:green, 13}, {:blue, 14}]))
    |> Enum.map(& &1.id)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&build_games/1)
    |> Enum.map(&power_of_minimum_cubes_needed/1)
    |> Enum.sum()
  end

  defp build_games(line) do
    [game_section, sets_section] = String.split(line, ":")
    %Game{id: parse_game_id(game_section), sets: parse_sets(sets_section)}
  end

  defp game_possible?(%Game{} = game, available_cubes) do
    Enum.all?(available_cubes, &enough_cubes_for_color?(&1, game))
  end

  defp enough_cubes_for_color?({color, total_available}, %Game{sets: sets}) do
    sets
    |> Enum.map(&Map.get(&1, color))
    |> Enum.all?(fn cubes_needed -> cubes_needed <= total_available end)
  end

  defp power_of_minimum_cubes_needed(%Game{} = game) do
    game
    |> minimum_cubes_needed()
    |> Enum.reduce(1, fn cubes_needed, acc -> acc * cubes_needed end)
  end

  defp minimum_cubes_needed(%Game{} = game) do
    [:red, :green, :blue]
    |> Enum.map(&maximum_cubes_for_color(&1, game))
  end

  defp maximum_cubes_for_color(color, %Game{sets: sets}) do
    sets
    |> Enum.map(&Map.get(&1, color))
    |> Enum.max()
  end

  defp parse_game_id("Game " <> id), do: String.to_integer(id)
  defp parse_game_id(_line), do: nil

  defp parse_sets(text) do
    text
    |> String.split(";")
    |> Enum.map(&parse_set/1)
  end

  defp parse_set(text) do
    text
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(%{red: 0, green: 0, blue: 0}, &update_set/2)
  end

  defp update_set(text, %{red: red, green: green, blue: blue}) do
    case String.split(text, " ") do
      [n, "red"] -> %{red: red + String.to_integer(n), green: green, blue: blue}
      [n, "green"] -> %{red: red, green: green + String.to_integer(n), blue: blue}
      [n, "blue"] -> %{red: red, green: green, blue: blue + String.to_integer(n)}
      _ -> %{red: red, green: green, blue: blue}
    end
  end
end
