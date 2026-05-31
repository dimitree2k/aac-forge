// aac-forge — LLM Provider Adapter Interface
//
// Abstract tool interface that every provider adapter implements.
// Skills reference tools by these names, making them provider-agnostic.
//
// Providers:
//   - adapter-deepseek.ts  (primary)
//   - adapter-gemini.ts
//   - adapter-claude.ts

// ---- Result Types ----

/** A single search-content match. */
export interface MatchResult {
  /** File path relative to the workspace root. */
  path: string
  /** 1-based line number. */
  line: number
  /** Full line text containing the match. */
  text: string
}

/** Result of a shell command execution. */
export interface CommandResult {
  /** Combined stdout. */
  stdout: string
  /** Combined stderr. */
  stderr: string
  /** Process exit code. 0 = success. */
  exitCode: number
}

/** A found file entry returned by searchFiles. */
export interface FileEntry {
  /** File path relative to the workspace root. */
  path: string
  /** 'file' or 'directory'. */
  type: 'file' | 'directory'
}

// ---- Read Options ----

export interface ReadFileOptions {
  /** Return only the first N lines. */
  head?: number
  /** Return only the last N lines. */
  tail?: number
  /** Inclusive 1-based line range, e.g. "50-100". */
  range?: string
}

export interface SearchContentOptions {
  /** Restrict search to a subdirectory. */
  path?: string
  /** Filename filter (glob or substring). */
  glob?: string
  /** Lines of context around each match (0–20). */
  context?: number
}

export interface RunCommandOptions {
  /** Override default timeout in seconds. */
  timeoutSec?: number
}

// ---- Adapter Interface ----

export interface ArchToolAdapter {
  /**
   * Read a file from the workspace.
   * Returns file content as a UTF-8 string.
   */
  readFile(path: string, options?: ReadFileOptions): Promise<string>

  /**
   * Recursively search file contents for a pattern.
   * Returns one match per line across all matching files.
   */
  searchContent(
    pattern: string,
    options?: SearchContentOptions,
  ): Promise<MatchResult[]>

  /**
   * Find files by name pattern (substring or regex match on basename).
   * Returns matching file paths.
   */
  searchFiles(pattern: string, path?: string): Promise<string[]>

  /**
   * Run a shell command in the project root.
   * Returns stdout, stderr, and exit code.
   */
  runCommand(
    command: string,
    options?: RunCommandOptions,
  ): Promise<CommandResult>

  /**
   * Create or overwrite a file with the given content.
   * Parent directories are created as needed.
   */
  writeFile(path: string, content: string): Promise<void>

  /**
   * Apply a SEARCH/REPLACE edit to an existing file.
   * `search` must be unique whitespace-sensitive text in the file.
   */
  editFile(path: string, search: string, replace: string): Promise<void>

  /**
   * Ask the user a question with optional multiple-choice options.
   * Returns the user's answer as a string.
   * May not be supported by all providers — falls back to structured output.
   */
  askUser(question: string, options?: string[]): Promise<string>

  /**
   * Report progress or set task status visible to the user.
   */
  setStatus(message: string): Promise<void>
}

// ---- Provider-specific adapters implement ArchToolAdapter ----
//
// Each adapter maps the abstract tool names to the concrete
// tool-calling format of its LLM platform:
//
//   DeepSeek → DeepSeek API function calling
//   Gemini   → Gemini function calling / tool use
//   Claude   → Claude tool use (Read, Grep, Glob, Bash, Write, Edit, etc.)
//
// The adapter is injected by the runtime; skills never know which
// provider is executing them.
