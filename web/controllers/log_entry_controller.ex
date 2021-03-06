defmodule Hyperledger.LogEntryController do
  use Hyperledger.Web, :controller
  
  alias Hyperledger.Repo
  alias Hyperledger.LogEntry

  plug :action

  def index(conn, _params) do
    entries = Repo.all(LogEntry)
    render conn, :index, entries: entries
  end
  
  def create(conn, params) do
    %{"logEntry" =>
      %{"id" => id, "view" => view, "command" => command, "data" => data},
      "prepareConfirmations" => prep_confs,
      "commitConfirmations" => commit_confs} = params
    prep_confs = Enum.map prep_confs, fn pc ->
      %{node_id: pc["nodeId"], signature: pc["signature"]}
    end
    commit_confs = Enum.map commit_confs, fn cc ->
      %{node_id: cc["nodeId"], signature: cc["signature"]}
    end
      
    case LogEntry.insert(id: id, view: view, command: command, data: data,
      prepare_confirmations: prep_confs, commit_confirmations: commit_confs) do
      {:ok, log_entry} ->
        conn
        |> put_status(:created)
        |> render :show, entry: log_entry
      {:error, _} ->
        conn
        |> put_status(:forbidden)
        |> render :error
    end
  end
end
