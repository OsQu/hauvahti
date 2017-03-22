defmodule Hauvahti.PollTimeout do
  defmacro assert_timeout(pattern, timeout \\ 1000, failure_message \\ nil) do
    do_assert_timeout(pattern, timeout, failure_message)
  end

  defp do_assert_timeout(pattern, timeout, failure_message) do
    quote do
      task = Task.async(fn ->
        assert_fun = fn
          (f, true) -> true
          (f, _) ->
            Process.sleep(100)
            f.(f, unquote(pattern))
        end

        assert_fun.(assert_fun, unquote(pattern))
      end)

      result = case Task.yield(task, unquote(timeout)) || Task.shutdown(task, unquote(timeout)) do
        {:ok, result} -> result
        nil -> flunk(unquote(failure_message) || "No truthy value after #{unquote(timeout)}ms")
      end
    end
  end
end
