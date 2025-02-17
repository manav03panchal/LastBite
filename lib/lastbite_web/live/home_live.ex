defmodule LastbiteWeb.HomeLive do
  use LastbiteWeb, :live_view

  on_mount {LastbiteWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Welcome")}
  end
end

