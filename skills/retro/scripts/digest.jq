# retro digest: one line per friction signal from a Claude Code transcript.
# Read the transcript with `jq -R -r -f digest.jq <session>.jsonl`, so a torn or
# malformed line is skipped instead of aborting the whole digest.
# Keeps: user turns, tool names, errors, hook blocks, permission denials,
# API errors and oversized tool results. Every quoted text is flattened,
# masked for obvious secrets and cut short; the digest is a map, not a copy.
# Adapted from mattpocock/skills@c55ee46 in-progress/retro (MIT).

def flat: tostring | gsub("\\s+"; " ");

def redact:
  gsub("(?<k>(api[_-]?key|access[_-]?key|token|secret|passw(or)?d|authorization|bearer|cookie)[\"']?\\s*[:=]?\\s*[\"']?((Bearer|Basic|token)\\s+)?)[^\\s\"',}]{6,}"; "\(.k)<REDACTED>"; "i")
  | gsub("(?<u>://[^\\s/:@\"']+):[^\\s/@\"']+@"; "\(.u):<REDACTED>@")
  | gsub("(?<u>(^|\\s)(-[uU]|--user|--proxy-user)(\\s+|=)[\"']?[^\\s:\"']+):[^\\s\"']+"; "\(.u):<REDACTED>")
  | gsub("(sk-[A-Za-z0-9_-]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|glpat-[A-Za-z0-9_-]{16,}|AKIA[0-9A-Z]{16}|xox[abprs]-[A-Za-z0-9-]{10,}|eyJ[A-Za-z0-9_-]{8,}\\.[A-Za-z0-9_-]{8,}\\.[A-Za-z0-9_-]+|-----BEGIN [A-Z ]*PRIVATE KEY-----)"; "<REDACTED>");

def cut($n): flat | redact | if length > $n then .[0:$n] + "..." else . end;

def text_of:
  if type == "string" then .
  elif type == "array" then map(if type == "object" then ((.text // .content // "") | tostring) else tostring end) | join(" ")
  else tostring end;

def kind:
  if test("hook error|BLOCKED"; "i") then "HOOK-BLOCK"
  elif test("denied|doesn't want to proceed|rejected"; "i") then "DENIED"
  else "ERROR" end;

input_line_number as $n
| (fromjson? // empty)
| select(type == "object")
| if .type == "user" and ((.isMeta // false) | not) then
    .message.content
    | if type == "string" then "L\($n) USER: " + cut(600)
      else
        .[]? | select(type == "object")
        | if .type == "text" then "L\($n) USER: " + (.text | cut(600))
          elif .type == "tool_result" then
            (.content | text_of) as $c
            | if .is_error == true then "L\($n) \($c | kind): " + ($c | cut(300))
              elif ($c | length) > 20000 then "L\($n) LARGE-RESULT: \($c | length) chars"
              else empty end
          else empty end
      end
  elif .type == "assistant" then
    .message.content[]? | select(type == "object" and .type == "tool_use")
    | "L\($n) TOOL \(.name)" + (if (.input | type) == "object" and (.input.description | type) == "string" then ": " + (.input.description | cut(120)) else "" end)
  elif .type == "system" then
    if .subtype == "api_error" then "L\($n) API-ERROR: " + ((.error // "") | cut(200))
    elif .subtype == "stop_hook_summary" and (.preventedContinuation == true or ((.hookErrors // []) | length) > 0) then
      "L\($n) HOOK-BLOCK Stop: " + ((.hookErrors // .stopReason // "") | cut(300))
    elif (.level // "") == "error" then "L\($n) SYSTEM-ERROR \(.subtype // ""): " + ((.content // "") | cut(300))
    else empty end
  elif .type == "attachment" then
    .attachment | select(type == "object")
    | if .type == "hook_cancelled" then "L\($n) HOOK-TIMEOUT \(.hookEvent // "") \(.hookName // "")"
      elif .type == "hook_success" then
        if ((.exitCode // 0) != 0) then "L\($n) HOOK-BLOCK \(.hookEvent // "") \(.hookName // "") exit \(.exitCode): " + ((.stderr // .content // "") | cut(300)) else empty end
      elif (.type | tostring | test("hook")) and (.type != "hook_additional_context") then
        "L\($n) HOOK-BLOCK \(.type) \(.hookEvent // "") \(.hookName // ""): " + ((.content // .stderr // "") | cut(300))
      elif .type == "queued_command" then "L\($n) USER (queued): " + ((.prompt // "") | cut(600))
      else empty end
  else empty end
