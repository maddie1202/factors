defmodule Quadratics do
  @doc """
    a, b and c will always come from this equation: ax^2 + bx + c = 0
    returns a string with binomial factors

    examples:
    factors(1, 7, 12) -> "(x + 3)(x + 4)"
    factors(2, 8, 8) -> "(x + 2)(x + 2)"
  """
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

  @doc """
    factors out the negative so a will be positive

    example: [-1, 2, 3] -> [1, -2, -3]
  """
  defp factor_negative ([a, b, c]) do
    cond do
      a < 0 -> Enum.map([a, b, c], &(&1 * -1))
      a > 0 -> [a, b, c]
    end
  end

  @doc """
    devides out greatest common factor

    example: [2, 4, 6] -> [1, 2, 3]
  """
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

  @doc """
    special numbers(sn_one and sn_two) are factors of a*c that add to b
    sometimes, this condition connot be met, this indicates that the quadratic cannot be factored

    n = a*c
    f = a pottential factor of n, starting at abs(n) and going down by one until it passes -abs(n)

    example: x^2 + 7x + 12 ->
    sn_one = 3
    son_two = 4
  """
  def special_numbers(n, f, b) when f < abs(n) * -1 do
    {:error, "cannot be factored"}
  end

  def special_numbers(n, f, b) when f != 0 and rem(n, f) == 0 and n/f + f == b do
    {Kernel.trunc(n/f), f}
  end

  def special_numbers(n, f, b) do
    special_numbers(n, f - 1, b)
  end

  @doc """
    the four positions refer to the coffeficiants and constants of the binomials:
    (1x + 2)(3x + 4)

    they are calculated with the following equations:
    p1 * p3 = a (p1 and p3 have to be factors of a)
    p2 * p4 = c (p2 and p4 have to be factors of c)
    p1 * p4 = sn_one (p1 and p4 have to be factors of sn_one)
    p2 * p3 = sn_two (p2 and p3 have to be factors of sn_two)

    p1 and p3 will always be positive but,
    p2 and p4 can be positive or negative so both cases have to be checked
  """
  def positions(a, c, sn_one, sn_two) do
    p1 = p1(a, sn_one, abs(a))
    p2 = p2(c, sn_two, abs(c))
    p3 = p3(a, sn_two, abs(a))
    p4 = p4(c, sn_one, abs(c))

    [p1, p2, p3, p4]
  end

   @doc """
    checks every possible value for p1 starting at a and going down until one
    chekcs using equations stated above
    same process for p3
   """
  def p1(a, sn_one, possible) when rem(a, possible) == 0 and rem(sn_one, possible) == 0 do
    possible
  end

  def p1(a, sn_one, possible) do
    p1(a, sn_one, possible - 1)
  end

  @doc """
      has to check whether p2 is positive or negative
      does this with the following equation: p2 * p3 = sn_two
      since p3 is always positive, p2 and sn_two have to have the same sign (p2 * sn_two > 0)
      same process for p4
    """
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
