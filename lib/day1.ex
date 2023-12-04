defmodule Advent2023.Day1 do
  def part1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&extract_calibration_number_for_part1/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&extract_calibration_number_for_part2/1)
    |> Enum.sum()
  end

  defp extract_calibration_number_for_part1(line) do
    digits = collect_proper_digits(line)
    first_digit(digits) * 10 + last_digit(digits)
  end

  defp extract_calibration_number_for_part2(line) do
    digits =
      line
      |> String.downcase()
      |> collect_digits([])
      |> Enum.reverse()

    first_digit(digits) * 10 + last_digit(digits)
  end

  defp collect_proper_digits(line) do
    line
    |> String.replace(~r/[^\d]/, "")
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp first_digit([]), do: 0
  defp first_digit([digit | _rest]), do: digit

  defp last_digit([]), do: 0
  defp last_digit([digit | []]), do: digit
  defp last_digit([_digit | rest]), do: last_digit(rest)

  defp collect_digits("", digits), do: digits

  defp collect_digits(line, digits) do
    case Regex.run(digit_regex(), line) do
      [digit | _] -> collect_digits(String.slice(line, 1..-1), [normalize_digit(digit) | digits])
      _ -> collect_digits(String.slice(line, 1..-1), digits)
    end
  end

  defp normalize_digit(digit) when digit in ["one", "1"], do: 1
  defp normalize_digit(digit) when digit in ["two", "2"], do: 2
  defp normalize_digit(digit) when digit in ["three", "3"], do: 3
  defp normalize_digit(digit) when digit in ["four", "4"], do: 4
  defp normalize_digit(digit) when digit in ["five", "5"], do: 5
  defp normalize_digit(digit) when digit in ["six", "6"], do: 6
  defp normalize_digit(digit) when digit in ["seven", "7"], do: 7
  defp normalize_digit(digit) when digit in ["eight", "8"], do: 8
  defp normalize_digit(digit) when digit in ["nine", "9"], do: 9
  defp normalize_digit(_digit), do: nil

  defp digit_regex, do: ~r/^(one|two|three|four|five|six|seven|eight|nine|\d)/
end
