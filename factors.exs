defmodule Reader do
  @moduledoc """
  To extract values a, b and c from a quadractic equation given a string
  """

  @doc """
  takes a quadratic equation in form ax^2 + bx + c as a string and returns values a, b and c in a list

  ## Parameters

  - `quadratic` - string with a quadratic equation in th form ax^2 + bx + c

  ## Examples

  - "2x^2 + 7x + 6" -> [2, 7, 6]
  - "7x + 6 + 2x^2" -> [2, 7, 6]
  """
  def string_to_coefficients(string) when is_binary(string) do
    terms = string
            |> String.trim()
            |> add_operator_to_beginning() #if the first term is positive, by convention there won't be a "+"
            |> String.replace("+", " + ")
            |> String.replace("-", " - ")
            |> String.split()
            |> Enum.chunk_every(2) #creates a list of terms: [operator, term]
            |> Enum.map(&(add_coefficient(&1))) #if the coefficient is 1, by convention there won't be a 1

    a_term = Enum.find(terms, &(a_b_or_c?(&1) == "a"))

    a = case a_term do
      nil ->
        "x^2 term not found"
      a_term ->
        extract_coefficient(a_term, "x^2")
    end

    b_term = Enum.find(terms, &(a_b_or_c?(&1) == "b"))

    b = case b_term do
      nil ->
        "x term not found"
      b_term ->
        extract_coefficient(b_term, "x")
    end

    c_term = Enum.find(terms, &(a_b_or_c?(&1) == "c"))

    c = case c_term do
      nil ->
        "constant term not found"
      c_term ->
        extract_coefficient(c_term, "constant")
    end

    [a, b, c]
  end

  # add "+" to the beginning of term if no operator is present
  defp add_operator_to_beginning(string) when is_binary(string) do
    unless(String.starts_with?(string, ["+", "-"])) do
      string = "+ " <> string
    end

    string
  end

  # add coefficient of one if no coefficient is present
  defp add_coefficient([operator, term]) when is_binary(term) do
    if(String.starts_with?(term, "x")) do
      term = "1" <> term
    end

    [operator, term]
  end

  defp a_b_or_c? ([_, term]) do
    cond do
      String.contains?(term, "x^2") ->
        "a"
      String.contains?(term, "x") ->
        "b"
      true ->
        "c"
    end
  end

  # extracts the variable (exmaple: x or x^2)and returns the remainning coefficient
  defp extract_coefficient([operator, term], variable) do
    term = String.replace(term, variable, "")

    coefficient = cond do
      string_number?(term) ->
        String.to_integer(term)
      true ->
        variable <> " term not found"
    end

    if(operator == "-") do
      coefficient = coefficient * -1
    end

    coefficient
  end

  @doc """
  returns false if a string contains anything other than numbers 0 to 9 or "-"

  ## Examples
  - "-1" -> true
  - "1234" -> true
  - "hello, world!" -> false
  - "1m23hfs7-ew" -> false
  """
  def string_number?(string) when is_binary(string) do
    string
    |> to_charlist()
    |> Enum.all?(&(&1 >= 48 and &1 <= 57 or &1 == 45))
  end

end

defmodule Quadratics do
  @moduledoc """
  Contains functions for interpreting quadratics in the form ax^2 + bx + c.
  """

  @doc """
  Returns a string with the binomial factors of a given quadratic.

  ## Parameters

  - `a` - Coefficient of the 2nd degree term.
  - `b` - Coefficient of the 1st degree term.
  - `c` - Constant term.

  ## Examples

    factors(1, 7, 12) -> "(x + 4)(x + 3)"
    factors(2, 8, 8) -> "(x + 2)(x + 2)"
  """
  def factors(a, b, c) when a != 0 and c != 0 do
    positions = [a, b, c]
                |> Simplify.simplify()
                |> Factors.factors()

    case positions do
       {:error, message} ->
        message

      other ->
        clean_up(positions)
    end

  end

  @doc """
  Returns a string with the binomial factors of a given quadratic.

  ## Parameters

  - `quadratic` - string containing a quadratic euqation in the form ax^2 + bx + c

  ## Examples

    factors(1, 7, 12) -> "(x + 4)(x + 3)"
    factors(2, 8, 8) -> "(x + 2)(x + 2)"
  """
  def factors(quadratic) when is_binary(quadratic) do
    [a, b, c] = Reader.string_to_coefficients(quadratic)

    cond do
      !is_integer(a) ->
        "cannot be factored"
      !is_integer(b) ->
        "cannot be factored"
      !is_integer(c) ->
        "cannot be factored"
      true ->
        factors(a, b, c)
    end
  end

  @doc """
  Formats `positions` as binomials in a human-readable format and returns the
  result as a string.
  """
  def clean_up(positions) do
    [p1, p2, p3, p4] = positions

    operator1 = if (p2 > 0), do: "+", else: "-"
    operator2 = if (p4 > 0), do: "+", else: "-"

    positions = positions
                |> Enum.map(&abs(&1)) # The operators are already defined above.
                |> Enum.map(&Integer.to_string()/1)

    [p1, p2, p3, p4] = positions

    # Hide any coefficients of 1.
    if (p1 == "1"), do: p1 = ""
    if (p3 == "1"), do: p3 = ""

    # Return the factors in the form (ax + b)(cx + d).
    "(#{p1}x #{operator1} #{p2})(#{p3}x #{operator2} #{p4})"
  end
end

defmodule Simplify do
  def simplify(values) when is_list(values) do
    values
    |> factor_negative()
    |> gcf()
    |> Enum.map(&Kernel.trunc/1)
  end

  @doc """
    factors out the negative so a will be positive

    example: [-1, 2, 3] -> [1, -2, -3]
  """
  defp factor_negative ([a, b, c]) do
    cond do
      a < 0 ->
        Enum.map([a, b, c], &(&1 * -1))

      a > 0 ->
        [a, b, c]

      true -> {:error, "a cannot equal 0"}
    end
  end


  defp gcf(values) when is_list(values) do
    min = abs(Enum.min(values))

    do_gcf(values, min)
  end

  # Divides out the greatest common factor.
  # Example: [2, 4, 6] -> [1, 2, 3]
  defp do_gcf(values, min) when is_list(values) and min == 0 do
    values
  end

  defp do_gcf(values, min) when is_list(values) do
    if ( Enum.all?(values, &(rem(&1, min) == 0)) ) do
      Enum.map(values, &(&1/min))
    else
      do_gcf(values, min - 1)
    end
  end
end

defmodule Factors do
  @moduledoc """
  Contains functions for factoring quadratics in the form ax^2 + bx + c.
  """

  @doc """
  Returns the coefficients and constants of a quadratic's factors as a list in
  the form `[p1, p2, p3, p4]`, where each value is positioned relative to its
  human-readable form.

  ie. [p1, p2, p3, p4] corresponds to (`p1`*x + `p2`)(`p3`*x + `p4`)

  ## Parameters

  - `a` - Coefficient of the 2nd degree term.
  - `b` - Coefficient of the 1st degree term.
  - `c` - Constant term.

  ## Examples

  For the quadratic x^2 + 7x + 12:

    iex> Factors.factors([1, 7, 12])
    [1, 4, 1, 3]

  For the quadratic 6x^2 + 5x - 6:

    iex> Factors.factors([6, 5, -6])
    [2, 3, 3, -2]
  """
  def factors([a, b, c]) do
    case special_numbers([a, b, c]) do
      {:error, message} ->
        {:error, message}

      {sn_one, sn_two} ->
        positions(a, c, sn_one, sn_two)
    end
  end

  @doc """
    Special numbers are factors of a*c and sum to b. If there are no numbers
    that meet this criteria, the quadratic cannot be factored and an error will
    be returned.

    Returns special numbers in the form `{sn_one, sn_two}`.

    ## Parameters

    - `a` - Coefficient of the 2nd degree term.
    - `b` - Coefficient of the 1st degree term.
    - `c` - Constant term.

    ## Examples

    For the quadratic x^2 + 7x + 12:

      iex> Factors.special_numbers([1, 7, 12])
      {3, 4}

    ## Implementation details for private function `do_special_numbers`

    - `n` - The product of `a` and `c` in a given quadratic.
    - `f` - A potential factor of `n`, starting at `abs(n)` and decrementing by
            one until `f` passes `-abs(n)`.
  """
  def special_numbers([a, b, c]) do
    do_special_numbers(a*c, abs(a*c), b)
  end

  defp do_special_numbers(n, f, b) when f < abs(n) * -1 do
    {:error, "cannot be factored"}
  end

  defp do_special_numbers(n, f, b) when f != 0 and rem(n, f) == 0 and n/f + f == b do
    {Kernel.trunc(n/f), f}
  end

  defp do_special_numbers(n, f, b) do
    do_special_numbers(n, f - 1, b)
  end

  @doc """
    Returns the coefficients and constants of a quadratic's factors as a list in
    the form `[p1, p2, p3, p4]`, where each value is positioned relative to its
    human-readable form.

    ie. [p1, p2, p3, p4] corresponds to (`p1`*x + `p2`)(`p3`*x + `p4`)

    ## Implementation details

    Each position is calculated with the following equations:

    1. p1 * p3 = a (p1 and p3 have to be factors of a)
    2. p2 * p4 = c (p2 and p4 have to be factors of c)
    3. p1 * p4 = sn_one (p1 and p4 have to be factors of sn_one)
    4. p2 * p3 = sn_two (p2 and p3 have to be factors of sn_two)

    `p1` and `p3` will always be positive, but `p2` and `p4` can be either
    positive or negative, so both cases must be checked.

    `p1` and `p3` use the same method, just as `p2` and `p4` do.
  """
  def positions(a, c, sn_one, sn_two) do
    p1 = foil_first(a, sn_one, abs(a))
    p2 = foil_last(c, sn_two, abs(c))
    p3 = foil_first(a, sn_two, abs(a))
    p4 = foil_last(c, sn_one, abs(c))

    [p1, p2, p3, p4]
  end

  # Checks every possible value for `p1`, starting at `a` and decrementing until
  # `possible` reaches 1. Checks using equations as explained in the docs for
  # Factors.positions/4.
  defp foil_first(a, sn_one, possible) when rem(a, possible) == 0 and rem(sn_one, possible) == 0 do
    possible
  end

  defp foil_first(a, sn_one, possible) do
    foil_first(a, sn_one, possible - 1)
  end

  # Must check whether `p2` is positive or negative. Checks with the equation:
  # `p2 * p3 = sn_two`. Because `p3` is always positive, `p2` and `sn_two` must
  # have the same sign (`p2 * sn_two > 0`)
  defp foil_last(c, sn_two, possible) do
    positive = (rem(c, possible) == 0 and rem(sn_two, possible) == 0 and sn_two * possible > 0)

    negative = (rem(c, possible) == 0 and rem(sn_two, possible) == 0 and sn_two * possible < 0)

    cond do
      positive ->
        possible

      negative ->
        possible * -1

      true ->
        foil_last(c, sn_two, possible - 1)
    end
  end
end
