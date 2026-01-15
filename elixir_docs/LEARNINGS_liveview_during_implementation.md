# Key Learnings: Phoenix LiveView Implementation

> **Implementation Context**: Knowledge Pool feature - file upload, topic assignment, content extraction, and search functionality

## 🎯 Core LiveView Patterns That Work

### 1. **Upload Handling - The Right Way**
```elixir
# ✅ GOOD: Allow uploads in mount, handle in connected state only
def mount(_params, _session, socket) do
  socket = 
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:knowledge_files,
      accept: ~w(.pdf .txt .md .markdown),
      max_entries: 5,
      max_file_size: 10_000_000
    )

  if connected?(socket) do
    {:ok, socket |> assign(:files, FileStorage.list_files())}
  else
    {:ok, socket |> assign(:files, [])}
  end
end

# ✅ GOOD: Use consume_uploaded_entries for file processing
def handle_event("save", _params, socket) do
  consume_uploaded_entries(socket, :knowledge_files, fn %{path: path}, entry ->
    bin = File.read!(path)
    safe_name = FileStorage.safe_filename(entry.client_name)
    :ok = FileStorage.save_file(safe_name, bin)
    Knowledge.Extractor.enqueue(safe_name, bin)  # Background processing
    {:ok, safe_name}
  end)
  {:noreply, assign_files_and_topics(socket)}
end
```

**🔑 Key Learning**: Always sanitize filenames and use `consume_uploaded_entries` for atomic file processing.

### 2. **State Management Patterns**
```elixir
# ✅ GOOD: Centralized assign helper functions
defp assign_files_and_topics(socket) do
  assign(socket,
    files: FileStorage.list_files(),
    topics: topicstorage.get_all_topics()
  )
end

# ✅ GOOD: Progressive enhancement with connected?/1
if connected?(socket) do
  # Heavy operations only after connection
  {:ok, socket |> load_expensive_data()}
else
  {:ok, socket |> assign_minimal_data()}
end
```

**🔑 Key Learning**: Use helper functions for complex assigns and leverage `connected?/1` for performance.

### 3. **Template Syntax - Critical Details**
```heex
<!-- ✅ GOOD: Proper conditional rendering -->
<div :if={is_nil(@selected_file)}>No selection</div>
<div :if={@file_metadata != %{}}>Has metadata</div>

<!-- ❌ BAD: These cause runtime errors -->
<div :if={not @selected_file}>Error prone</div>
<div :if={not Enum.empty?(@file_metadata)}>Runtime error</div>

<!-- ✅ GOOD: Safe iteration -->
<div :for={filename <- @files} phx-click="select-file" phx-value-filename={filename}>
  {filename}
</div>
```

**🔑 Key Learning**: Be explicit with nil checks and avoid complex expressions in templates.

## 🏗️ GenServer Architecture Lessons

### 1. **Application Supervision Strategy**
```elixir
# ✅ GOOD: Add to application supervision tree
children = [
  LiveAiChat.CsvStorage,
  LiveAiChat.FileStorage,      # ← New services
  LiveAiChat.topicstorage,       # ← New services
  {Task.Supervisor, name: LiveAiChat.TaskSupervisor},
  LiveAiChatWeb.Endpoint
]
```

**🔑 Key Learning**: Always add GenServers to supervision tree, never start them manually in production.

### 2. **GenServer API Patterns**
```elixir
# ✅ GOOD: Clear API distinction
def save_file(name, bin), do: GenServer.call(__MODULE__, {:save, name, bin})     # Sync
def update_topics_for_file(f, t), do: GenServer.cast(__MODULE__, {:update_topics, f, t})  # Async

# ✅ GOOD: Safe filename handling
def safe_filename(name) do
  name 
  |> Path.basename() 
  |> String.replace(~r/[^\w\.-]/, "_")
end
```

**🔑 Key Learning**: Use `call` for reads/confirmations, `cast` for fire-and-forget operations.

### 3. **Background Task Management**
```elixir
# ✅ GOOD: Supervised background tasks
def enqueue(filename, bin) do
  Task.Supervisor.start_child(@task_supervisor, fn -> 
    extract_and_save(filename, bin) 
  end)
end
```

**🔑 Key Learning**: Always use `Task.Supervisor` for background work, never unsupervised `Task.start`.

## 🧪 Testing Strategies & Pitfalls

### 1. **GenServer Testing Challenges**
```elixir
# ❌ PROBLEM: GenServer already started by application
setup do
  {:ok, _pid} = FileStorage.start_link([])  # Crashes!
end

# ✅ SOLUTION: Handle already_started
setup do
  case FileStorage.start_link([]) do
    {:ok, _pid} -> :ok
    {:error, {:already_started, _pid}} -> :ok
  end
end
```

**🔑 Key Learning**: Application-level GenServers create test isolation challenges. Handle gracefully.

### 2. **Test Directory Management**
```elixir
# ✅ GOOD: Isolated test directories
setup do
  test_dir = "priv/test_#{:rand.uniform(1000)}"
  File.mkdir_p!(test_dir)
  Application.put_env(:app, :upload_dir, test_dir)
  
  # Clean up existing files
  case File.ls(test_dir) do
    {:ok, files} -> Enum.each(files, &File.rm(Path.join(test_dir, &1)))
    _ -> :ok
  end
  
  on_exit(fn -> File.rm_rf!(test_dir) end)
end
```

**🔑 Key Learning**: Use unique test directories and clean up between tests for isolation.

### 3. **LiveView Testing Patterns**
```elixir
# ✅ GOOD: Setup test data in LiveView tests
describe "file management" do
  setup do
    :ok = FileStorage.save_file("test.txt", "content")
    topicstorage.update_topics_for_file("test.txt", ["test"])
    :ok
  end

  test "displays files", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/knowledge")
    html = render(view)
    assert html =~ "test.txt"
  end
end
```

**🔑 Key Learning**: Set up test data in describe blocks, use `render/1` for additional assertions.

## 🔒 Security & Best Practices

### 1. **File Upload Security**
```elixir
# ✅ GOOD: Filename sanitization
defp safe_filename(name) do
  name 
  |> Path.basename()           # Remove path traversal
  |> String.replace(~r/[^\w\.-]/, "_")  # Remove dangerous chars
end

# ✅ GOOD: File type validation
accept: ~w(.pdf .txt .md .markdown),
max_entries: 5,
max_file_size: 10_000_000
```

**🔑 Key Learning**: Never trust user filenames. Always sanitize and validate.

### 2. **Error Handling Patterns**
```elixir
# ✅ GOOD: Graceful error handling
defp extract_and_save(file, bin) do
  case extract_content(file, bin) do
    {:ok, content, content_type} ->
      case extract_with_ai(file, content, content_type) do
        {:ok, data} -> topicstorage.save_extraction(file, data)
        err -> Logger.error("Extraction failed: #{inspect(err)}")
      end
    err -> Logger.error("Content read failed: #{inspect(err)}")
  end
end
```

**🔑 Key Learning**: Chain operations with pattern matching, log errors with context.

## 🎨 UI/UX Insights

### 1. **Modern Component Design**
```heex
<!-- ✅ GOOD: Consistent design system -->
<div class="card bg-base-200 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">
      <.icon name="hero-cloud-arrow-up" class="h-5 w-5" />
      Upload Files
    </h2>
```

**🔑 Key Learning**: Use consistent component patterns and design system (DaisyUI works great).

### 2. **Progressive Enhancement**
```heex
<!-- ✅ GOOD: Drag & drop with fallback -->
<section 
  phx-drop-target={@uploads.knowledge_files.ref}
  class="border-2 border-dashed border-base-300"
>
  <p>Drop files here or click to select</p>
  <.live_file_input upload={@uploads.knowledge_files} />
</section>
```

**🔑 Key Learning**: Always provide fallbacks for enhanced interactions.

### 3. **Loading States & Feedback**
```heex
<!-- ✅ GOOD: Progress feedback -->
<div :for={entry <- @uploads.knowledge_files.entries}>
  <progress class="progress progress-primary" value={entry.progress} max="100">
    {entry.progress}%
  </progress>
</div>
```

**🔑 Key Learning**: Provide immediate feedback for all user actions.

## 🔗 Integration Patterns

### 1. **Adding Features to Existing Apps**
```elixir
# ✅ GOOD: Non-invasive routing
scope "/", LiveAiChatWeb do
  pipe_through :browser
  live "/", ChatLive           # Existing
  live "/knowledge", KnowledgeLive  # New, non-breaking
end
```

**🔑 Key Learning**: Add new routes without breaking existing functionality.

### 2. **Component Organization**
```
lib/live_ai_chat_web/
├── live/
│   ├── chat_live.ex          # Existing
│   ├── knowledge_live.ex     # New feature
│   └── knowledge_live.html.heex
└── components/               # Shared components
```

**🔑 Key Learning**: Organize by feature, keep shared components separate.

## ⚡ Performance Considerations

### 1. **Efficient State Updates**
```elixir
# ✅ GOOD: Minimal assigns
def handle_event("select-file", %{"filename" => filename}, socket) do
  metadata = topicstorage.get_extraction(filename)
  {:noreply, assign(socket, 
    selected_file: filename,
    file_metadata: metadata,
    new_topics: topics_to_string(Map.get(socket.assigns.topics, filename))
  )}
end
```

**🔑 Key Learning**: Only update what changes, avoid full page reloads.

### 2. **Background Processing**
```elixir
# ✅ GOOD: Non-blocking operations
Knowledge.Extractor.enqueue(filename, content)  # Returns immediately
{:noreply, socket}  # UI updates instantly
```

**🔑 Key Learning**: Keep UI responsive with background processing for heavy operations.

## 🚨 Common Pitfalls & Solutions

### 1. **Template Runtime Errors**
```heex
<!-- ❌ BAD: Runtime error -->
<div :if={not Enum.empty?(@metadata)}>

<!-- ✅ GOOD: Safe check -->
<div :if={@metadata != %{}}>
```

### 2. **GenServer State Pollution**
```elixir
# ❌ BAD: Shared state between tests
# ✅ GOOD: Clean state or use unique names per test
```

### 3. **Upload Error Handling**
```elixir
# ✅ GOOD: Handle all upload error types
defp error_to_string(:too_large), do: "File too large (max 50MB)"
defp error_to_string(:too_many_files), do: "Too many files (max 5)"
defp error_to_string(:not_accepted), do: "File type not supported"
```

## 🎯 Next Project Recommendations

1. **Start with GenServer design** - Plan your state management first
2. **Test isolation strategy** - Design for test independence from day one
3. **File handling security** - Always sanitize, validate, and limit uploads
4. **Background processing** - Use Task.Supervisor for any heavy operations
5. **Progressive UI** - Build with `connected?/1` optimization in mind
6. **Error boundaries** - Plan error handling at every layer
7. **Component reusability** - Design components for multiple contexts

## 🛠️ Build Process & DevOps Learnings

### 1. **Precommit Script Best Practices**
```bash
# ✅ GOOD: Comprehensive precommit checks
#!/bin/bash
set -e  # Exit on any error

# 1. Dependencies check
mix deps.get && mix deps.unlock --check-unused

# 2. Code formatting
mix format --check-formatted

# 3. Compilation with warnings as errors
mix compile --warnings-as-errors

# 4. Static analysis (if available)
mix credo || echo "Credo not available, skipping..."

# 5. Security analysis (if available)  
mix sobelow || echo "Sobelow not available, skipping..."

# 6. Full test suite
mix test

# 7. Type checking (if configured)
mix dialyzer || echo "Dialyzer not configured, skipping..."
```

**🔑 Key Learning**: Create a comprehensive precommit script early. It catches issues before they become problems.

### 2. **Application Configuration Patterns**
```elixir
# ✅ GOOD: Environment-specific configs
# test.exs
config :live_ai_chat,
  upload_dir: System.get_env("TEST_UPLOAD_DIR", "priv/test_uploads")

# Test overrides
Application.put_env(:live_ai_chat, :upload_dir, test_specific_dir)
```

**🔑 Key Learning**: Use application configuration for paths and directories to enable test isolation.

### 3. **Debugging Workflow That Works**
```elixir
# ✅ GOOD: Systematic debugging approach
1. Run single failing test: mix test path/to/test.exs:line_number
2. Check GenServer state: :sys.get_state(MyGenServer)  
3. Add IO.inspect with labels: |> IO.inspect(label: "before_operation")
4. Use --trace for detailed test output: mix test --trace
5. Check application startup: iex -S mix
```

**🔑 Key Learning**: Follow a systematic debugging process rather than random fixes.

## 📚 Documentation That Helped

- **Phoenix LiveView Uploads Guide** - Essential for file handling
- **GenServer OTP Guide** - Critical for understanding supervision
- **Phoenix Testing Guide** - Invaluable for LiveView test patterns
- **DaisyUI Components** - Excellent for rapid UI development
- **Elixir Application Configuration** - Crucial for test isolation

## 🚀 Implementation Workflow That Worked

### 1. **Phase-by-Phase Development**
```
Phase 1: Backend Services (GenServers + supervision)
Phase 2: UI Layer (LiveView + routing)  
Phase 3: Integration & Testing
Phase 4: Polish & Documentation
```

**🔑 Key Learning**: Implement backend services first, then UI. Test each phase thoroughly before moving on.

### 2. **Test-First Mindset**
- Write failing tests before implementation
- Use test isolation patterns from day one
- Mock external dependencies (AI client, file system for some tests)
- Test error conditions, not just happy paths

**🔑 Key Learning**: Comprehensive testing saves hours of debugging later.

### 3. **Constraint-Driven Development**
- No new dependencies → Forces creative solutions with existing stack
- CSV persistence → Learn file-based data patterns
- Security-first approach → Always sanitize and validate

**🔑 Key Learning**: Constraints often lead to simpler, more maintainable solutions.

---

**💡 Final Insight**: LiveView enables rapid feature development, but requires careful attention to state management, testing isolation, security practices, and systematic debugging workflows. The patterns established here will scale well to additional features and provide a solid foundation for future Phoenix projects.
