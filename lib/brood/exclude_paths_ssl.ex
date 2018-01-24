defmodule Brood.ExcludePathsSSL do
  require Logger

  def init([exclude_paths: paths]) do
    ssl_opts = Plug.SSL.init([])
    {paths, ssl_opts}
  end

  def call(conn, {exclude_paths, ssl_opts}) do
    case true in exclude_redirect(conn, exclude_paths) do
      true -> conn
      false -> Plug.SSL.call(conn, ssl_opts)
    end
  end

  def exclude_redirect(conn, exclude_paths) do
    exclude_paths |> Enum.map(fn path ->
      partial = conn.path_info |> Enum.slice(0..(Enum.count(path)-1))
      Logger.debug "Checking #{inspect partial} against #{inspect path}"
      case partial do
        [_h | _t] = ^path ->
          Logger.debug "True"
          true
        _ ->
          Logger.debug "False"
          false
      end
    end)
  end
end
