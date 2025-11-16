# NUDO Specification v0.2

**Nudo** (Nushell TODO) is a project-based TODO list manager using Markdown format, optimized for both CLI manipulation and manual editing.

## Design Goals

- **Human-readable**: Plain markdown that can be edited in any text editor
- **CLI-friendly**: Simple command-line interface for quick task management
- **Project-organized**: Separate task lists for different projects/contexts
- **LLM-compatible**: Clear, parseable format suitable for AI-assisted task management
- **Version-controllable**: Plain text files that work well with git
- **Dotfile-friendly**: Works with symlinks for dotfile management tools (e.g., GNU Stow)

## Directory Structure

```
~/.config/nudo/
├── state.json           # Tracks current active project
└── projects/            # Individual project markdown files
    ├── default.md
    ├── work.md
    ├── personal.md
    └── ...
```

### State File

**Location**: `~/.config/nudo/state.json`

**Format**:
```json
{
  "current_project": "project-name"
}
```

**Behavior**:
- Created automatically on first run with `"current_project": "default"`
- Updated when switching projects via `switch-project` command
- Persists the active project between nudo invocations

## File Format

### Project File Location

- **Directory**: `~/.config/nudo/projects/`
- **File naming**: `<project-name>.md`
- **Example**: `~/.config/nudo/projects/work.md`
- **Symlink support**: Files can be symlinks (for dotfile managers like Stow)

### Structure

Each project file consists of:

1. A level-1 heading: `# TODO`
2. A blank line
3. A level-3 heading: `### Tasks`
4. Zero or more task items

### Task Syntax

Tasks use GitHub Flavored Markdown checkbox syntax:

```markdown
- [ ] Incomplete task description
- [x] Completed task description
```

**Rules:**
- Task lines MUST start with `- [`
- Checkbox MUST contain either a space `[ ]` (incomplete) or lowercase x `[x]` (complete)
- Task description follows the checkbox with a single space separator
- Task descriptions can contain any text except newlines

**Example valid file:**

```markdown
# TODO

### Tasks
- [ ] Buy groceries
- [x] Write documentation
- [ ] Review pull requests
```

**Example empty file:**

```markdown
# TODO

### Tasks
```

### Parsing Rules

The CLI parser:
- Reads all lines from the current project's file
- Identifies task lines by checking if they start with `- [`
- Extracts completion status by checking for `[x]` (complete) vs `[ ]` (incomplete)
- Extracts task text using regex: `^- \[[x ]\] (.*)$`
- Ignores all non-task lines (headers, blank lines, comments, etc.)

**Important:** Only lines matching the exact pattern `- [ ] ` or `- [x] ` are recognized as tasks.

## CLI Behavior

All task commands operate on the **current active project** as stored in `state.json`.

### Project Management Commands

#### `nudo create-project <name>` | `nudo cp <name>`

Creates a new project with the specified name.

**Behavior:**
- Creates `~/.config/nudo/projects/<name>.md` with empty task list
- Initializes file with canonical format
- Does NOT switch to the new project automatically
- Shows error if project already exists

**Output (success):**
```
✓ Created project: <name>
  Location: /path/to/projects/<name>.md
```

**Output (error):**
```
✗ Project '<name>' already exists
```

**Examples:**
```bash
nudo create-project work       # Full command
nudo cp personal               # Short alias
```

#### `nudo switch-project <name>` | `nudo sp <name>`

Switches the active project.

**Behavior:**
- Updates `state.json` with new current project
- Validates that project file exists
- All subsequent task commands operate on this project
- Shows error if project doesn't exist

**Output (success):**
```
✓ Switched to project: <name>
```

**Output (error):**
```
✗ Project '<name>' does not exist
  Use 'nudo create-project <name>' to create it
```

**Examples:**
```bash
nudo switch-project work       # Full command
nudo sp personal               # Short alias
```

#### `nudo projects` | `nudo lsp`

Lists all available projects.

**Behavior:**
- Scans `~/.config/nudo/projects/` for `.md` files
- Supports both regular files and symlinks
- Indicates current active project with `*` marker
- Shows helpful message if no projects exist

**Output format:**
```
Projects:
    default
  * work (current)
    personal
```

**Empty state:**
```
No projects yet!
Create one with: nudo create-project <name>
```

**Examples:**
```bash
nudo projects                  # Full command
nudo lsp                       # Short alias
```

### Task Management Commands

All task commands operate on the current active project.

#### `nudo` (no arguments)

Lists all tasks in the current project with numbered index.

**Output format:**
```
<number>. [<status>] <task description>
```

Where:
- `<number>`: 1-based index
- `<status>`: `○` for incomplete, `✓` for complete
- `<task description>`: The task text

**Empty state:**
```
No todos yet!
```

#### `nudo add <task>` | `nudo a <task>`

Adds a new task to the current project.

**Behavior:**
- Appends task as incomplete (`- [ ]`) to current project file
- Task description is all arguments joined with spaces
- Quotes are optional (all args are concatenated)
- Writes entire file atomically

**Output:**
```
✓ Added: <task description>
```

**Examples:**
```bash
nudo add "Buy groceries"       # Full command with quotes
nudo add Buy groceries         # Full command without quotes
nudo a "Fix login bug"         # Short alias
nudo a Review PR #123          # Short alias without quotes
```

#### `nudo remove <number>` | `nudo rm <number>`

Removes a task by its 1-based index number from the current project.

**Behavior:**
- Validates number is within range [1, task_count]
- Removes task at index (number - 1)
- Re-writes file without removed task
- Task numbers are recalculated on next list

**Output (success):**
```
✓ Removed: <task description>
```

**Output (error):**
```
✗ Invalid task number: <number>
```

**Output (invalid input):**
```
✗ Task number must be a number
```

**Examples:**
```bash
nudo remove 1                  # Full command
nudo rm 2                      # Alias
```

#### `nudo list` | `nudo ls` | `nudo lst`

Lists all tasks in the current project. Alias for `nudo` (no arguments).

**Examples:**
```bash
nudo list                      # Full command
nudo ls                        # Short alias
nudo lst                       # Alternative short alias
```

#### `nudo clear` | `nudo clr`

Removes all tasks from the current project, leaving an empty but valid file structure.

**Behavior:**
- Deletes all task lines from current project
- Preserves header structure (`# TODO\n\n### Tasks\n`)
- Does NOT delete the project file itself

**Output:**
```
✓ All todos cleared
```

**Examples:**
```bash
nudo clear                     # Full command
nudo clr                       # Short alias
```

### Other Commands

#### `nudo help` | `nudo h`

Displays help information with usage, commands, examples, and current project status.

**Output includes:**
- All available commands with aliases
- Current active project
- Current project file location

**Examples:**
```bash
nudo help                      # Full command
nudo h                         # Short alias
```

## Command Reference

### Quick Reference Table

| Command | Aliases | Description |
|---------|---------|-------------|
| `nudo` | - | List tasks in current project |
| `nudo add <task>` | `a` | Add a task |
| `nudo remove <number>` | `rm` | Remove a task |
| `nudo list` | `ls`, `lst` | List all tasks |
| `nudo clear` | `clr` | Clear all tasks |
| `nudo create-project <name>` | `cp` | Create a project |
| `nudo switch-project <name>` | `sp` | Switch to a project |
| `nudo projects` | `lsp` | List all projects |
| `nudo help` | `h` | Show help |

## File Writing Behavior

When tasks are modified (add, remove, clear):

1. **Atomic write**: The entire project file is rewritten
2. **Format preservation**: Always writes canonical format:
   - `# TODO` header
   - Blank line
   - `### Tasks` section header
   - Task items (if any)
   - Trailing newline (if tasks exist)

3. **Task ordering**: Tasks maintain insertion order within each project
4. **No metadata preservation**: Comments, extra sections, or formatting outside the task list are lost
5. **Project isolation**: Changes to one project never affect other projects

**Important for LLMs:** Manual edits to project files are preserved UNTIL a CLI command modifies that specific project file. Once modified via CLI, the file is rewritten in canonical format.

## Integration Guidelines

### For Manual Editing

You can directly edit any project file in `~/.config/nudo/projects/`:

- Add tasks by inserting lines: `- [ ] Task description`
- Mark complete by changing `[ ]` to `[x]`
- Reorder tasks by moving lines
- Add comments or extra sections (will be lost on next CLI write to that project)
- Create new project files manually (must follow naming convention `<name>.md`)
- Edit `state.json` to change current project (must be valid JSON)

### For LLM Integration

**Discovering current project:**
1. Read `~/.config/nudo/state.json`
2. Parse JSON to get `current_project` value
3. Construct project file path: `~/.config/nudo/projects/<current_project>.md`

**Reading tasks from a project:**
1. Parse project file (e.g., `~/.config/nudo/projects/work.md`)
2. Extract lines matching pattern: `^- \[([x ])\] (.+)$`
3. Group 1 is status (`x` = complete, space = incomplete)
4. Group 2 is task description

**Writing tasks to a project:**
1. Determine target project (current from state.json or specific project)
2. Generate file in canonical format (see File Format section)
3. Write atomically to `~/.config/nudo/projects/<project>.md`
4. Validate all lines match task pattern before writing

**Listing projects:**
1. List files in `~/.config/nudo/projects/` matching `*.md`
2. Extract project names by removing `.md` extension
3. Compare against `current_project` from state.json to identify active project

**Switching projects:**
1. Verify target project file exists in `~/.config/nudo/projects/`
2. Update `state.json`: `{"current_project": "<new-project>"}`
3. Write atomically with proper JSON formatting

**Validation:**
- Project files MUST start with `# TODO`
- Project files MUST contain `### Tasks` section
- All task lines MUST match: `^- \[[x ]\] .+$`
- Empty task descriptions are invalid
- state.json MUST be valid JSON with `current_project` field
- state.json MUST reference an existing project file

### For Dotfile Management

Nudo is compatible with dotfile managers like GNU Stow:

- Project files can be symlinks (detected via `type in [file symlink]`)
- State file can be a symlink
- Directory structure is preserved
- All file operations follow symlinks correctly

## Error Handling

Current implementation error handling:

**Task operations:**
- Invalid task numbers show error message
- Non-numeric task numbers show error message
- Empty task lists show friendly "No todos yet!" message
- Malformed tasks are silently ignored (skipped during parsing)

**Project operations:**
- Creating duplicate project shows error
- Switching to non-existent project shows error with helpful suggestion
- Missing directories are auto-created
- Missing state file is auto-created with default project

## Known Limitations

**Current v0.2:**
- No support for task metadata (tags, dates, priorities)
- No support for subtasks or task hierarchy
- No support for multiple sections within a project
- No task completion toggling (must remove and re-add, or edit manually)
- No task editing (must remove and re-add with changes)
- No project renaming command
- No project deletion command
- Manual edits outside canonical format are lost on CLI write
- No undo/history
- No project templates
- No task migration between projects
- State file only tracks one current project (no project stack/history)

## Version History

- **v0.2** (2025-01-16): Project system and command aliases
  - Added project support (create, switch, list)
  - Multi-project task isolation
  - State persistence via state.json
  - Command aliases for faster usage (cp, sp, lsp, a, lst, clr, h)
  - Symlink support for dotfile managers
  - Project-scoped operations

- **v0.1** (2025-01-16): Initial specification
  - Basic CRUD operations (add, remove, list, clear)
  - Markdown checkbox format
  - Single task list support

---

*This specification will evolve as new features are added to nudo.*
