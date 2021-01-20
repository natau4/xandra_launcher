defmodule XandraLauncher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Xandra, cassandra_params()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XandraLauncher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cassandra_params() do
    params = Mix.Project.config()[:app] |> Application.fetch_env!(:xandra)
    fun = &Xandra.execute(&1, "USE #{params[:keyspace]}")

    [
      name: :xandra,
      pool_size: params[:pool_size],
      nodes: [params[:host]],
      after_connect: fun,
      queue_target: params[:queue_target],
      queue_interval: params[:queue_interval]
    ]
  end
end
