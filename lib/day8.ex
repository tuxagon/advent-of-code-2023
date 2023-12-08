defmodule Advent2023.Day8 do
  alias Advent2023.MathHelper

  def part1(input) do
    input
    |> parse_input()
    |> count_steps_for_exact_match()
  end

  def part2(input) do
    input
    |> parse_input()
    |> then(fn {instructions, nodes} ->
      # Brute force would work, but be incredibly complicated
      get_nodes_for_suffix("A", nodes)
      |> Enum.map(fn node ->
        count_steps_for_a_node_matching_suffix({instructions, nodes}, node)
      end)
      |> then(&MathHelper.lcm_list/1)
    end)
  end

  defp count_steps_for_exact_match({instructions, nodes}, {node_label, count_from} \\ {"AAA", 0}) do
    node = get_node(node_label, nodes)

    instructions
    |> Enum.reduce({node, count_from}, fn ins, acc ->
      case acc do
        {{"ZZZ", _children}} -> acc
        _ -> follow_instruction(ins, acc, nodes)
      end
    end)
    |> then(fn result ->
      case result do
        {{"ZZZ", _children}, steps} ->
          steps

        {{label, _children}, steps} ->
          count_steps_for_exact_match({instructions, nodes}, {label, steps})
      end
    end)
  end

  defp count_steps_for_a_node_matching_suffix({instructions, nodes}, node, count_from \\ 0) do
    instructions
    |> Enum.reduce({node, count_from}, fn ins, acc ->
      if node_has_suffix?("Z", elem(acc, 0)) do
        acc
      else
        follow_instruction(ins, acc, nodes)
      end
    end)
    |> then(fn result ->
      if node_has_suffix?("Z", elem(result, 0)) do
        elem(result, 1)
      else
        count_steps_for_a_node_matching_suffix(
          {instructions, nodes},
          elem(result, 0),
          elem(result, 1)
        )
      end
    end)
  end

  defp follow_instruction("L", {{_label, {left, _right}}, steps}, nodes),
    do: {get_node(left, nodes), steps + 1}

  defp follow_instruction("R", {{_label, {_left, right}}, steps}, nodes),
    do: {get_node(right, nodes), steps + 1}

  defp get_node(label, nodes) do
    case Map.get(nodes, label) do
      nil ->
        raise "Invalid node: #{label}"

      node ->
        {label, node}
    end
  end

  defp get_nodes_for_suffix(suffix, nodes) do
    nodes
    |> Enum.filter(&node_has_suffix?(suffix, &1))
  end

  defp node_has_suffix?(suffix, {label, _children}), do: String.ends_with?(label, suffix)

  defp parse_input(input) do
    case String.split(input, "\n\n") do
      [instructions, nodes] ->
        {parse_instructions(instructions), parse_nodes(nodes)}

      _ ->
        raise "Invalid input"
    end
  end

  defp parse_instructions(instructions), do: String.split(instructions, "", trim: true)

  defp parse_nodes(nodes) do
    nodes
    |> String.split("\n", trim: true)
    |> Enum.map(fn node_text ->
      case Regex.named_captures(
             ~r/(?<label>\w+)\s*=\s*\((?<left>\w+),\s*(?<right>\w+)\)/,
             node_text
           ) do
        %{"label" => label, "left" => left, "right" => right} ->
          {label, {left, right}}

        _ ->
          raise "Invalid node: #{node_text}"
      end
    end)
    |> Map.new()
  end
end
