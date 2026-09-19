# frozen_string_literal: true

module Overcommit::Hook::CommitMsg
  # Rejects AI attribution in commit messages.
  #
  # The built-in MessageFormat check only inspects the subject line, so a
  # trailer in the body passes it. The tool that wrote a commit is not
  # information anyone needs from `git log`, and `git blame` already attributes
  # the work to whoever committed it.
  class NoAiAttribution < Base
    TOOLS = /claude|copilot|cursor|chatgpt|openai|gpt-\d|gemini|codex|devin|aider/i

    PATTERNS = {
      /^\s*co-authored-by:.*#{TOOLS}/i => "a Co-Authored-By trailer naming a tool",
      /generated (?:with|by).*#{TOOLS}/i => "a generated-with footer",
      /🤖/ => "the robot emoji"
    }.freeze

    def run
      found = PATTERNS.filter_map do |pattern, description|
        description if commit_message_lines.any? { |line| line.match?(pattern) }
      end

      return :pass if found.empty?

      [:fail, "Remove #{found.join(' and ')} from the commit message."]
    end
  end
end
