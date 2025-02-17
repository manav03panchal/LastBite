defmodule LastbiteWeb.FoodShareLive do
  use LastbiteWeb, :live_view
  alias Lastbite.Sharing
  alias Lastbite.Sharing.FoodItem

  @upload_directory "uploads"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    # Create upload directory if it doesn't exist
    upload_path = Path.join("priv/static", @upload_directory)
    File.mkdir_p!(upload_path)

    # Create initial changeset
    changeset = FoodItem.changeset(%FoodItem{}, %{})

    socket =
      socket
      |> assign(:food_items, Sharing.list_available_food_items())
      |> assign(:form, to_form(changeset))
      |> allow_upload(:food_image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 5_000_000
      )

    {:ok, socket}
  end

  def handle_event("save", %{"food_item" => food_item_params}, socket) do
    IO.puts("==== SAVE EVENT START ====")
    IO.puts("Uploads: #{inspect(socket.assigns.uploads)}")
    IO.puts("Food params before: #{inspect(food_item_params)}")

    image_url = handle_image_upload(socket)

    IO.puts("Image URL after upload: #{inspect(image_url)}")
    expires_at = DateTime.utc_now() |> DateTime.add(3600, :second)

    food_item_params =
      food_item_params
      |> Map.put("expires_at", expires_at)
      |> Map.put("image_url", image_url)

    IO.puts("Final params: #{inspect(food_item_params)}")
    IO.puts("==== SAVE EVENT END ====")

    case Sharing.create_food_item(food_item_params) do
      {:ok, _food_item} ->
        {:noreply,
         socket
         |> assign(food_items: Sharing.list_available_food_items())
         |> put_flash(:info, "Food item posted successfully!")}

      {:error, changeset} ->
        IO.puts("Error: #{inspect(changeset)}")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"food_item" => food_item_params}, socket) do
    changeset =
      %FoodItem{}
      |> FoodItem.changeset(food_item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("claim", params, socket) do
    case params do
      %{"id" => id, "value" => _} ->
        Sharing.claim_food_item(id)
        {:noreply, assign(socket, food_items: Sharing.list_available_food_items())}

      _ ->
        {:noreply, socket}
    end
  end

  defp handle_image_upload(socket) do
    IO.puts("==== UPLOAD START ====")

    uploaded_files =
      consume_uploaded_entries(socket, :food_image, fn %{path: path}, entry ->
        IO.puts("Entry: #{inspect(entry)}")
        IO.puts("Path: #{inspect(path)}")

        ext = Path.extname(entry.client_name)
        unique_filename = "#{entry.uuid}#{ext}"
        dest = Path.join("priv/static/uploads", unique_filename)

        IO.puts("Destination: #{dest}")

        # Create directory
        File.mkdir_p!(Path.dirname(dest))

        # Try to copy file
        case File.cp(path, dest) do
          :ok ->
            IO.puts("File copied successfully")
            {:ok, "/uploads/#{unique_filename}"}

          {:error, reason} ->
            IO.puts("File copy failed: #{inspect(reason)}")
            {:error, reason}
        end
      end)

    IO.puts("Uploaded files result: #{inspect(uploaded_files)}")
    IO.puts("==== UPLOAD END ====")

    case uploaded_files do
      [url | _] -> url
      _ -> nil
    end
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, food_items: Sharing.list_available_food_items())}
  end

  defp time_remaining(expires_at) do
    now = DateTime.utc_now()
    diff = DateTime.diff(expires_at, now, :minute)
    "#{diff} minutes left"
  end
end

