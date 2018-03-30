defmodule Quadratics do
  def factors(a, b, c) do
  @doc """
    a, b and c will always come from this equation: ax^2 + bx + c
  """
    positions = [a, b, c]
    |> Simplify.simplify()
    |> Factors.factors()

    output = case positions do
      {:error, message} -> message
      other -> clean_up(positions)
    end

  end

  def clean_up(positions) do
  @doc """
    puts positions into binomials in a clean string (no coefficiants of 1, etc.)
  """
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
      other -> p1
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
  @doc """
    factors out the negative so a will be positive
  """
    cond do
      a < 0 -> Enum.map([a, b, c], &(&1 * -1))
      a > 0 -> [a, b, c]
    end
  end

  defp gcf(values, min) when min == 0 do
    values
  end

  defp gcf(values, min) do

  @doc """
    devides out greatest common factor
  """
    case Enum.all?(values, &(rem(&1, min) == 0)) do
      true -> Enum.map(values, &(&1/min))
      false -> gcf(values, min - 1)
    end
  end
end

defmodule Factors do
  def factors([a, b, c]) do
  @doc """
    special numbers(sn_one and sn_two) are factors of a*c that add to b
    sometimes, this condition connot be met, this indicates that the quadratic cannot be factored
  """
    case special_numbers(a*c, abs(a*c), b) do
      {:error, message} -> message
      {sn_one, sn_two} -> positions(a, c, sn_one, sn_two)
    end
  end

  def special_numbers(n, f, b) when f < abs(n) * -1 do
  @doc """
    n = a*c
    f = a pottential factor of n, starting at abs(n) and going down by one until it passes -abs(n)
  """
    {:error, "cannot be factored"}
  end

  def special_numbers(n, f, b) when f != 0 and rem(n, f) == 0 and n/f + f == b do
    {Kernel.trunc(n/f), f}
  end

  def special_numbers(n, f, b) do
    special_numbers(n, f - 1, b)
  end

  def positions(a, c, sn_one, sn_two) do

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
    p1 = p1(a, sn_one, abs(a))
    p2 = p2(c, sn_two, abs(c))
    p3 = p3(a, sn_two, abs(a))
    p4 = p4(c, sn_one, abs(c))

    [p1, p2, p3, p4]
  end

   def p1(a, sn_one, possible) when rem(a, possible) == 0 and rem(sn_one, possible) == 0 do
   @doc """
    checks every possible value for p1 starting at a and going down until one
    chekcs using equations stated above
    same process for p3
   """
    possible
  end

  def p1(a, sn_one, possible) do
    p1(a, sn_one, possible - 1)
  end

  def p2(c, sn_two, possible) do

    @doc """
      has to check whether p2 is positive or negative
      does this with the following equation: p2 * p3 = sn_two
      since p3 is always positive, p2 and sn_two have to have the same sign (p2 * sn_two > 0)
      same process for p4
    """

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
