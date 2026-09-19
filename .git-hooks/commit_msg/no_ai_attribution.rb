# frozen_string_literal: true

module Overcommit::Hook::CommitMsg
  # MessageFormat only inspects the subject, so body trailers pass it.
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
