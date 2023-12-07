defmodule Advent2023.Day7 do
  defmodule Hand do
    defstruct [:cards, :bid, :type]
  end

  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&put_hand_type_without_jokers/1)
    |> organize_hands(&card_strength_without_joker/1)
    |> calculate_winnings()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&put_hand_type_with_jokers/1)
    |> organize_hands(&card_strength_with_joker/1)
    |> calculate_winnings()
  end

  defp put_hand_type_without_jokers(%Hand{cards: cards} = hand) do
    cards
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort()
    |> List.to_tuple()
    |> hand_type()
    |> then(&Map.put(hand, :type, &1))
  end

  def put_hand_type_with_jokers(%Hand{cards: cards} = hand) do
    cards
    |> Enum.frequencies()
    |> Enum.map(fn {card, count} -> {count, card} end)
    |> Enum.sort(fn {count_a, _}, {count_b, _} ->
      count_a < count_b
    end)
    |> List.to_tuple()
    |> adjust_for_jokers()
    |> hand_type()
    |> then(&Map.put(hand, :type, &1))
  end

  defp organize_hands(hands, comparer) do
    hands
    |> Enum.group_by(& &1.type)
    |> Enum.map(fn {{_name, value}, hands} ->
      {value, sort_hands(hands, comparer)}
    end)
    |> Enum.sort(fn {value_a, _}, {value_b, _} ->
      value_a < value_b
    end)
    |> Enum.flat_map(&elem(&1, 1))
  end

  defp sort_hands(hands, card_strength) do
    Enum.sort(hands, fn %Hand{} = left_hand, %Hand{} = right_hand ->
      compare_cards(left_hand.cards, right_hand.cards, card_strength)
    end)
  end

  defp compare_cards([a | rest_a], [b | rest_b], card_strength) do
    if card_strength.(a) == card_strength.(b) do
      compare_cards(rest_a, rest_b, card_strength)
    else
      card_strength.(a) < card_strength.(b)
    end
  end

  defp calculate_winnings(hands) do
    1..Enum.count(hands)
    |> Enum.zip(hands)
    |> Enum.map(fn {rank, %Hand{bid: bid}} ->
      rank * bid
    end)
    |> Enum.sum()
  end

  defp hand_type({5}), do: {:five_of_a_kind, 7}
  defp hand_type({1, 4}), do: {:four_of_a_kind, 6}
  defp hand_type({2, 3}), do: {:full_house, 5}
  defp hand_type({1, 1, 3}), do: {:three_of_a_kind, 4}
  defp hand_type({1, 2, 2}), do: {:two_pairs, 3}
  defp hand_type({1, 1, 1, 2}), do: {:one_pair, 2}
  defp hand_type({1, 1, 1, 1, 1}), do: {:high_card, 1}

  defp card_strength_without_joker("A"), do: 14
  defp card_strength_without_joker("K"), do: 13
  defp card_strength_without_joker("Q"), do: 12
  defp card_strength_without_joker("J"), do: 11
  defp card_strength_without_joker("T"), do: 10
  defp card_strength_without_joker(card), do: String.to_integer(card)

  defp card_strength_with_joker("A"), do: 13
  defp card_strength_with_joker("K"), do: 12
  defp card_strength_with_joker("Q"), do: 11
  defp card_strength_with_joker("J"), do: 1
  defp card_strength_with_joker("T"), do: 10
  defp card_strength_with_joker(card), do: String.to_integer(card)

  # 5         JJJJJ always  5
  # 1,4       AJJJJ becomes 5
  # 1,4       JAAAA becomes 5
  # 1,4       AKKKK stays   1,4
  # 2,3       AAJJJ becomes 5
  # 2,3       JJAAA becomes 5
  # 2,3       AAKKK stays   2, 3
  # 1,1,3     AKJJJ becomes 1, 4
  # 1,1,3     JAKKK becomes 1, 4
  # 1,1,3     AKQQQ stays   1, 1, 3
  # 1,2,2     AKKJJ becomes 1, 4
  # 1,2,2     JAAKK becomes 2, 3
  # 1,2,2     AKKQQ stays   1, 2, 2
  # 1,1,1,2   AKQJJ becomes 1, 1, 3
  # 1,1,1,2   JAKQQ becomes 1, 1, 3
  # 1,1,1,2   AKQTT stays   1, 1, 1, 2
  # 1,1,1,1,1 AKQJT becomes 1, 1, 1, 2
  # 1,1,1,1,1 AKQT9 stays   1, 1, 1, 1
  defp adjust_for_jokers({{5, _}}), do: {5}
  defp adjust_for_jokers({{1, card1}, {4, card2}}) when card1 == "J" or card2 == "J", do: {5}
  defp adjust_for_jokers({{1, _card1}, {4, _card2}}), do: {1, 4}
  defp adjust_for_jokers({{2, card1}, {3, card2}}) when card1 == "J" or card2 == "J", do: {5}
  defp adjust_for_jokers({{2, _card1}, {3, _card2}}), do: {2, 3}

  defp adjust_for_jokers({{1, card1}, {1, card2}, {3, card3}})
       when card1 == "J" or card2 == "J" or card3 == "J",
       do: {1, 4}

  defp adjust_for_jokers({{1, _card1}, {1, _card2}, {3, _card3}}), do: {1, 1, 3}

  defp adjust_for_jokers({{1, _card1}, {2, card2}, {2, card3}})
       when card2 == "J" or card3 == "J",
       do: {1, 4}

  defp adjust_for_jokers({{1, card1}, {2, _card2}, {2, _card3}})
       when card1 == "J",
       do: {2, 3}

  defp adjust_for_jokers({{1, _card1}, {2, _card2}, {2, _card3}}), do: {1, 2, 2}

  defp adjust_for_jokers({{1, card1}, {1, card2}, {1, card3}, {2, card4}})
       when card1 == "J" or card2 == "J" or card3 == "J" or card4 == "J",
       do: {1, 1, 3}

  defp adjust_for_jokers({{1, _card1}, {1, _card2}, {1, _card3}, {2, _card4}}), do: {1, 1, 1, 2}

  defp adjust_for_jokers({{1, card1}, {1, card2}, {1, card3}, {1, card4}, {1, card5}})
       when card1 == "J" or card2 == "J" or card3 == "J" or card4 == "J" or card5 == "J",
       do: {1, 1, 1, 2}

  defp adjust_for_jokers({{1, _card1}, {1, _card2}, {1, _card3}, {1, _card4}, {1, _card5}}),
    do: {1, 1, 1, 1, 1}

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [cards, bid] = String.split(line, " ")

      %Hand{
        cards: String.graphemes(cards),
        bid: String.to_integer(bid)
      }
    end)
  end
end
