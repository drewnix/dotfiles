# Nudo - Nushell TODO Manager Module
# A project-based TODO list manager using Markdown format

# Initialize nudo environment and paths
export-env {
    $env.NUDO_DIR = ($env.HOME | path join ".config" "nudo")
    $env.NUDO_PROJECTS = ($env.NUDO_DIR | path join "projects")
    $env.NUDO_STATE = ($env.NUDO_DIR | path join "state.json")

    # Initialize directories
    if (not ($env.NUDO_DIR | path exists)) {
        mkdir $env.NUDO_DIR
    }
    if (not ($env.NUDO_PROJECTS | path exists)) {
        mkdir $env.NUDO_PROJECTS
    }

    # Initialize state file with default project
    if (not ($env.NUDO_STATE | path exists)) {
        {current_project: "default"} | to json | save --raw $env.NUDO_STATE
    }
}

# Get current project from state
def get_current_project []: nothing -> string {
    let state = (open $env.NUDO_STATE)
    $state.current_project
}

# Set current project in state
def set_current_project [project: string] {
    {current_project: $project} | to json | save --force --raw $env.NUDO_STATE
}

# Get the todo file path for the current project
def get_todo_file []: nothing -> path {
    let project = (get_current_project)
    $env.NUDO_PROJECTS | path join $"($project).md"
}

# Initialize a project file if it doesn't exist
def init_project_file [file_path: string, project_name: string] {
    if (not ($file_path | path exists)) {
        # Capitalize first letter of project name for title
        let first_char = ($project_name | str substring 0..<1 | str upcase)
        let rest = ($project_name | str substring 1..)
        let title = $first_char + $rest
        $"# ($title)\n\n### Tasks\n" | save --raw $file_path
    }
}

# Parse markdown todos into structured data (returns table)
def load_todos []: nothing -> table {
    let project = (get_current_project)
    let todo_file = (get_todo_file)
    init_project_file $todo_file $project
    let content = (open $todo_file | lines)

    mut tasks = []
    mut current_task: record<number: int, description: string, completed: bool, priority: any, tags: list<string>, due_date: any, created: any, updated: any> = {
        number: 0
        description: ""
        completed: false
        priority: null
        tags: []
        due_date: null
        created: null
        updated: null
    }
    mut task_index = 0
    mut has_task = false

    for line in $content {
        # Check if this is a task line
        if ($line | str starts-with "- [") {
            # Save previous task if exists
            if $has_task {
                $tasks = ($tasks | append $current_task)
                $task_index = $task_index + 1
            }

            # Parse new task
            let completed = ($line | str contains "[x]")
            let description = ($line | str replace --regex '^- \[[x ]\] ' '')

            $current_task = {
                number: ($task_index + 1)
                description: $description
                completed: $completed
                priority: null
                tags: []
                due_date: null
                created: null
                updated: null
            }
            $has_task = true
        } else if ($line | str starts-with "  - ") and $has_task {
            # This is a metadata line
            let metadata = ($line | str trim | str substring 2..)  # Remove "- "

            if ($metadata | str contains ": ") {
                let parts = ($metadata | split row ": ")
                let key = ($parts | first | str trim)
                let value = ($parts | skip 1 | str join ": " | str trim)

                match $key {
                    "priority" => { $current_task.priority = $value }
                    "tags" => {
                        $current_task.tags = ($value | split row "," | each { |t| $t | str trim })
                    }
                    "due" | "due_date" => { $current_task.due_date = $value }
                    "created" => { $current_task.created = $value }
                    "updated" => { $current_task.updated = $value }
                    _ => {}  # Ignore unknown metadata
                }
            }
        }
    }

    # Don't forget the last task
    if $has_task {
        $tasks = ($tasks | append $current_task)
    }

    $tasks
}

# Get project name from markdown file
def get_project_name []: nothing -> string {
    let todo_file = (get_todo_file)
    if ($todo_file | path exists) {
        let first_line = (open $todo_file | lines | first)
        if ($first_line | str starts-with "# ") {
            $first_line | str substring 2..
        } else {
            let project = (get_current_project)
            let first_char = ($project | str substring 0..<1 | str upcase)
            let rest = ($project | str substring 1..)
            $first_char + $rest
        }
    } else {
        let project = (get_current_project)
        let first_char = ($project | str substring 0..<1 | str upcase)
        let rest = ($project | str substring 1..)
        $first_char + $rest
    }
}

# Save todos to markdown file
def save_todos [todos: table] {
    let todo_file = (get_todo_file)
    let project_name = (get_project_name)
    let header = $"# ($project_name)\n\n### Tasks\n"

    let task_lines = (
        $todos
        | each { |todo|
            let checkbox = if $todo.completed { "[x]" } else { "[ ]" }
            mut lines = [$"- ($checkbox) ($todo.description)"]

            # Add metadata if present
            if $todo.priority != null {
                $lines = ($lines | append $"  - priority: ($todo.priority)")
            }
            if ($todo.tags | is-not-empty) {
                let tags_str = ($todo.tags | str join ", ")
                $lines = ($lines | append $"  - tags: ($tags_str)")
            }
            if $todo.due_date != null {
                $lines = ($lines | append $"  - due: ($todo.due_date)")
            }
            if $todo.created != null {
                $lines = ($lines | append $"  - created: ($todo.created)")
            }
            if $todo.updated != null {
                $lines = ($lines | append $"  - updated: ($todo.updated)")
            }

            $lines | str join "\n"
        }
        | str join "\n"
    )

    let content = if ($todos | is-empty) {
        $header
    } else {
        $header + $task_lines + "\n"
    }

    $content | save --force --raw $todo_file
}

# Add a new todo
export def "nudo add" [
    ...task: string  # Task description (all args joined)
] {
    let task_text = ($task | str join " ")

    if ($task_text | is-empty) {
        print "Usage: nudo add <task description>"
        return
    }

    let todos = (load_todos)
    let next_number = if ($todos | is-empty) { 1 } else { (($todos | last | get number) + 1) }
    let now = (date now | format date "%Y-%m-%dT%H:%M:%S")

    let new_todo = {
        number: $next_number
        description: $task_text
        completed: false
        priority: null
        tags: []
        due_date: null
        created: $now
        updated: $now
    }

    let updated = ($todos | append $new_todo)
    save_todos $updated
    print $"✓ Added: ($task_text)"
}

# Remove a todo by number
export def "nudo remove" [
    task_num: int  # Task number to remove
] {
    let todos = (load_todos)
    if ($task_num < 1 or $task_num > ($todos | length)) {
        print $"✗ Invalid task number: ($task_num)"
        return
    }
    let task_text = $todos | get ($task_num - 1) | get description
    let updated = ($todos | where number != $task_num)

    # Renumber tasks
    let renumbered = ($updated | enumerate | each { |it|
        $it.item | update number ($it.index + 1)
    })

    save_todos $renumbered
    print $"✓ Removed: ($task_text)"
}

# List all todos (returns table)
export def "nudo list" []: nothing -> table {
    load_todos
}

# Clear all todos
export def "nudo clear" [] {
    save_todos []
    print "✓ All todos cleared"
}

# Create a new project
export def "nudo create-project" [
    project: string  # Project name
] {
    let project_file = ($env.NUDO_PROJECTS | path join $"($project).md")
    if ($project_file | path exists) {
        print $"✗ Project '($project)' already exists"
        return
    }
    init_project_file $project_file $project
    print $"✓ Created project: ($project)"
    print $"  Location: ($project_file)"
}

# Switch to a different project
export def "nudo switch-project" [
    project: string  # Project name to switch to
] {
    let project_file = ($env.NUDO_PROJECTS | path join $"($project).md")
    if (not ($project_file | path exists)) {
        print $"✗ Project '($project)' does not exist"
        print $"  Use 'nudo create-project ($project)' to create it"
        return
    }
    set_current_project $project
    print $"✓ Switched to project: ($project)"
}

# List all projects
export def "nudo projects" [] {
    let current = (get_current_project)
    let project_list = (ls $env.NUDO_PROJECTS | where type in [file symlink] and name =~ '.md$' | get name | each { |path|
        $path | path basename | str replace '.md' ''
    })

    if ($project_list | is-empty) {
        print "No projects yet!"
        print "Create one with: nudo create-project <name>"
        return
    }

    print "Projects:"
    $project_list | each { |project|
        if $project == $current {
            print $"  * ($project) \(current\)"
        } else {
            print $"    ($project)"
        }
    } | ignore
}

# Show help message
export def "nudo help" [] {
    let current_project = (get_current_project)
    let todo_file = (get_todo_file)

    print "nudo - A project-based TODO list manager using Markdown"
    print ""
    print "USAGE:"
    print "  nudo <command> [args]"
    print ""
    print "TASK COMMANDS:"
    print "  list                  List all tasks (returns table)"
    print "  add <task>            Add a new task"
    print "  remove <number>       Remove a task by number"
    print "  clear                 Clear all tasks in current project"
    print ""
    print "PROJECT COMMANDS:"
    print "  create-project <name> Create a new project"
    print "  switch-project <name> Switch to a different project"
    print "  projects              List all projects"
    print ""
    print "OTHER COMMANDS:"
    print "  help                  Show this help message"
    print ""
    print "EXAMPLES:"
    print "  nudo create-project work          # Create a work project"
    print "  nudo switch-project work          # Switch to work project"
    print "  nudo add Fix bug in login         # Add task to current project"
    print "  nudo list | where priority == high # Filter high priority tasks"
    print "  nudo list | select description     # Show only descriptions"
    print "  nudo projects                      # List all projects"
    print "  nudo remove 1                      # Remove first task"
    print ""
    print $"CURRENT PROJECT: ($current_project)"
    print $"FILE LOCATION: ($todo_file)"
    print ""
    print "You can also manually edit the markdown files directly!"
}

# Convenience aliases
export alias "nudo ls" = nudo list
export alias "nudo a" = nudo add
export alias "nudo rm" = nudo remove
export alias "nudo clr" = nudo clear
export alias "nudo cp" = nudo create-project
export alias "nudo sp" = nudo switch-project
export alias "nudo lsp" = nudo projects
export alias "nudo h" = nudo help
