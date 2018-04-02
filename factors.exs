defmodule Quadratics do
  def factors(a, b, c) when a != 0 and c != 0 do
    positions = [a, b, c]
    |> Simplify.simplify()
    |> Factors.factors()

   case positions do
      "cannot be factored" -> "cannot be factored"
      other -> clean_up(positions)
    end

  end

  def clean_up(positions) do

    [p1, p2, p3, p4] = positions

    operator1 = case p2 > 0 do
      true -> "+"
      false -> "-"
    end

    operator2 = case p4 > 0 do
      true -> "+"
      false -> "-"
    end

    positions = positions
    |> Enum.map(&abs(&1)) #because the operators are defined above
    |> Enum.map(&Integer.to_string()/1)

    [p1, p2, p3, p4] = positions

    #removes unecessary coefficiant of 1
    p1 = case p1 do
      "1" -> ""
      other -> p1
    end

    p3 = case p3 do
      "1" -> ""
      other -> p3
    end

     "(" <> p1 <> "x " <> operator1 <> " " <> p2 <> ")(" <> p3 <> "x " <> operator2 <> " " <> p4 <> ")"
  end
end

defmodule Simplify do
  def simplify(values) when is_list(values) do
    values
    |> factor_negative()
    |> gcf(abs(Enum.min(values)))
    |> Enum.map(&Kernel.trunc/1)
  end

  defp factor_negative ([a, b, c]) do
    cond do
      a < 0 -> Enum.map([a, b, c], &(&1 * -1))
      a > 0 -> [a, b, c]
    end
  end

  defp gcf(values, min) when min == 0 do
    values
  end

  defp gcf(values, min) do
    case Enum.all?(values, &(rem(&1, min) == 0)) do
      true -> Enum.map(values, &(&1/min))
      false -> gcf(values, min - 1)
    end
  end
end

defmodule Factors do
  def factors([a, b, c]) do
    case special_numbers(a*c, abs(a*c), b) do
      {:error, message} -> message
      {sn_one, sn_two} -> positions(a, c, sn_one, sn_two)
    end
  end

  def special_numbers(n, f, b) when f < abs(n) * -1 do
    {:error, "cannot be factored"}
  end

  def special_numbers(n, f, b) when f != 0 and rem(n, f) == 0 and n/f + f == b do
    {Kernel.trunc(n/f), f}
  end

  def special_numbers(n, f, b) do
    special_numbers(n, f - 1, b)
  end

  def positions(a, c, sn_one, sn_two) do
    p1 = p1(a, sn_one, abs(a))
    p2 = p2(c, sn_two, abs(c))
    p3 = p3(a, sn_two, abs(a))
    p4 = p4(c, sn_one, abs(c))

    [p1, p2, p3, p4]
  end

  def p1(a, sn_one, possible) when rem(a, possible) == 0 and rem(sn_one, possible) == 0 do
    possible
  end

  def p1(a, sn_one, possible) do
    p1(a, sn_one, possible - 1)
  end

  def p2(c, sn_two, possible) do
    positive = case rem(c, possible) == 0 and rem(sn_two, possible) == 0 and sn_two * possible > 0 do
      true -> true
      false -> false
    end

    negative = case rem(c, possible) == 0 and rem(sn_two, possible) == 0 and sn_two * possible < 0 do
      true -> true
      false -> false
    end

    cond do
      positive == true -> possible
      negative  == true -> possible * -1
      true -> p2(c, sn_two, possible-1)
    end
  end

  def p3(a, sn_two, possible) when rem(a, possible) == 0 and rem(sn_two, possible) == 0 do
    possible
  end

  def p3(a, sn_two, possible) do
    p3(a, sn_two, possible - 1)
  end

  def p4(c, sn_one, possible) do
    positive = case rem(c, possible) == 0 and rem(sn_one, possible) == 0 and sn_one * possible > 0 do
      true -> true
      false -> false
    end

    negative = case rem(c, possible) == 0 and rem(sn_one, possible) == 0 and sn_one * possible < 0 do
      true -> true
      false -> false
    end

    cond do
      positive -> possible
      negative -> possible * -1
      true -> p2(c, sn_one, possible-1)
    end
  end


end
