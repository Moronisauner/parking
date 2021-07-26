defmodule Parking.Server do
  use GenServer

  @seconds_to_ignore :timer.minutes(5) / 1000

  @seconds_in_hour 3600

  @doc """
  This functions defines the parking configuration.

  # params:
    - full_price: The price charget for an hour. Default: float `1.0`.
    - half_price: The price for 30 min. Default: float `0.5`.
    - spaces: The spaces available for parking. Default: int `10`.
  """
  def init(args) do
    full_price = Keyword.get(args, :full_price, 1.0)
    half_price = Keyword.get(args, :half_price, 0.5)
    spaces = Keyword.get(args, :spaces, 10)

    {:ok,
     %{
       full_price: full_price,
       half_price: half_price,
       spaces: Map.new(0..(spaces - 1), &{&1, nil})
     }}
  end

  def handle_call({:checkin, car}, _from, state) do
    state
    |> checkin_car(car)
    |> case do
      {:ok, space, new_state} ->
        {:reply, space, new_state}

      {:error, :no_space} ->
        {:reply, {:error, :no_space}, state}
    end
  end

  def handle_call({:checkout, car}, _from, state) do
    state
    |> checkout_car(car)
    |> case do
      {:ok, cost, elapsed_time, new_state} ->
        {:reply, {cost, elapsed_time}, new_state}

      {:error, :no_car} ->
        {:reply, {:error, :no_car, car}, state}
    end
  end

  defp checkin_car(state, car) do
    case Enum.find_index(state.spaces, &(elem(&1, 1) == nil)) do
      nil -> {:error, :no_space}
      space -> {:ok, space, put_in(state, [:spaces, space], {NaiveDateTime.utc_now(), car})}
    end
  end

  defp checkout_car(state, car) do
    case Enum.find_index(state.spaces, &match?({_, {_, ^car}}, &1)) do
      nil ->
        {:error, :no_car}

      position ->
        {{price, time}, new_state} =
          get_and_update_in(state, [:spaces, position], fn {start, _} ->
            time = NaiveDateTime.diff(NaiveDateTime.utc_now(), start)

            {{price(time, state), time}, nil}
          end)

        {:ok, price, time, new_state}
    end
  end

  defp price(seconds, state) do
    price = state.full_price * Float.ceil(seconds / @seconds_in_hour)

    if rem(seconds, @seconds_in_hour) <= @seconds_to_ignore do
      price
    else
      price + state.fraction_price
    end
  end
end
