defmodule Advent2023.Day4 do
  defmodule Card do
    defstruct [:id, :winning_numbers, :scratched_numbers]
  end

  def part1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_card/1)
    |> Enum.map(&calculate_points/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_card/1)
    |> Enum.into(%{}, fn card -> {card.id, card} end)
    |> calculate_total_scratchcards()
  end

  defp calculate_total_scratchcards(cards_by_id) do
    cards_by_id
    |> Map.values()
    |> Enum.map(&total_scratchcards_earned_from_card(&1, cards_by_id, 1))
    |> Enum.sum()
  end

  defp total_scratchcards_earned_from_card(%Card{id: id} = card, cards_by_id, total) do
    case total_matching(card) do
      0 ->
        total

      n ->
        Enum.reduce((id + 1)..(id + n), total, fn next_id, acc ->
          case cards_by_id[next_id] do
            nil -> acc
            next_card -> 1 + total_scratchcards_earned_from_card(next_card, cards_by_id, acc)
          end
        end)
    end
  end

  defp total_matching(%Card{winning_numbers: winning, scratched_numbers: scratched}) do
    Enum.count(scratched, &Enum.member?(winning, &1))
  end

  defp calculate_points(%Card{} = card) do
    case total_matching(card) do
      0 -> 0
      n -> Integer.pow(2, n - 1)
    end
  end

  defp parse_card(text) do
    [card_section, winning_section, scratched_section] = String.split(text, [":", "|"])

    %Card{
      id: parse_card_id(card_section),
      winning_numbers: parse_numbers(winning_section),
      scratched_numbers: parse_numbers(scratched_section)
    }
  end

  defp parse_card_id("Card " <> id), do: id |> String.trim() |> String.to_integer()
  defp parse_card_id(_line), do: nil

  defp parse_numbers(text) do
    text
    |> String.split(" ", trim: true)
    |> Enum.map(fn val ->
      val
      |> String.trim()
      |> String.to_integer()
    end)
  end
end
