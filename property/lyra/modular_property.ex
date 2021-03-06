defmodule ModularProperty do
  use ExUnit.Case
  use PropCheck

  @norm round(:math.pow(2, Application.fetch_env!(:lyra, :digest)[:size]))

  property "interval membership under modular arithmetic" do
    import Lyra.Modular, only: [epsilon?: 2]
    forall {u, v} <- bounds() do
      forall x <- point() do
        assert epsilon?(x, exclude: u, include: v) == correct(x, u, v)
      end
    end
  end

  ## Our Model

  defp correct(x, u, v) when u < v do
    between?(x, include: u + 1, exclude: v + 1)
  end
  defp correct(_, u, v) when u === v do
    true
  end
  defp correct(x, u, v) when u > v do
    between?(x, include: u + 1, exclude: biggest()) or between?(x, include: 0, exclude: v + 1)
  end

  ## Test Ancillaries

  defp bounds do
    {bound(), bound()}
  end

  defp bound do
    natural()
  end

  defp point do
    natural()
  end

  defp natural do
    let i <- oneof([nat(), large_int()]) do
      if abs(i) < biggest(), do: abs(i)
    end
  end

  defp between?(x, [include: start, exclude: stop]) do
    start <= x and x < stop
  end

  def biggest do
    @norm
  end
end
