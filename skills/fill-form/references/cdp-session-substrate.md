# The logged-in session substrate: Chrome attached over CDP

The `fill-form` skill does NOT start a browser itself. It works on top of a
logged-in session that the **human** prepares during pre-flight. The split of roles
is strict: the browser and the login belong to the human; attaching over CDP and
filling belong to the agent; **the password is never given to the agent**.

The substrate is simply a Chrome session attached over the Chrome DevTools Protocol
(CDP): you start Chrome with `--remote-debugging-port=9222` yourself, log in by
hand, and the agent attaches to that running browser. This file covers only what the
skill needs as its input.

## What the human does once (pre-flight)

1. Start **Google Chrome** with an open CDP port. A separate browser keeps the
   automated session apart from your everyday one; Chrome Beta works well for this,
   and so does your regular Chrome with a dedicated profile folder.
   `--user-data-dir` is **mandatory**: without it Chrome refuses remote debugging on
   the default profile, and logins would not survive between launches.

   macOS (Chrome Beta shown; for regular Chrome use `Google Chrome.app` and its binary):
   ```bash
   "/Applications/Google Chrome Beta.app/Contents/MacOS/Google Chrome Beta" \
     --remote-debugging-port=9222 \
     --user-data-dir="$HOME/.chrome-cdp-profile" &
   ```
   Linux: `google-chrome-beta --remote-debugging-port=9222 --user-data-dir="$HOME/.chrome-cdp-profile" &` (or `google-chrome` with the same flags)
   Windows (PowerShell): `Start-Process "C:\Program Files\Google\Chrome Beta\Application\chrome.exe" -ArgumentList '--remote-debugging-port=9222', "--user-data-dir=$env:USERPROFILE\.chrome-cdp-profile"`

2. Log in by hand to the sites you need (subscription databases, personal accounts,
   social networks) right in that window. The logins are stored in the profile
   folder and persist between launches.

This works across platforms (Windows/macOS/Linux). Note that Google publishes no
official arm64 Chrome Beta package for Linux, only amd64.

## What the skill checks before it starts

**CDP port liveness:**
```bash
curl -s http://localhost:9222/json/version
```
A response with the browser's fields → the port is listening and you can attach.
(Windows: `curl.exe` or `Invoke-RestMethod http://localhost:9222/json/version`.)

**Attach and readiness of the chain:**
```bash
timeout 15 agent-browser --cdp 9222 snapshot -i
```
A tree with `@eN` refs came back → the agent is in the logged-in tab.

## The attach invariant

- `--cdp 9222` on **every** command: this is the attach to the running Chrome.
  The alternative is a one-off `agent-browser connect 9222`, but `--cdp` on every
  command is more reliable and does not depend on the state of the daemon.
- Without `--cdp`, a command launches **a separate, detectable Chromium with no
  logins**, not our session. This is the most common hidden failure.
- `--session <name> connect 9222` is a bug: `connect` under `--session` creates an
  empty `about:blank` tab instead of attaching to the existing ones (tested on
  v0.22.3, same behaviour in v0.26). Do not use it.
- Several tabs under one login go through `tab` (shared cookies), NOT through
  `--session` (in v0.26 that is a separate isolated browser with its own cookies).

A session can also be kept between runs in other ways (`--state <file>`,
`--session-name`, the auth vault `auth save/login`), but this substrate does not
need them: the `--user-data-dir` profile itself holds the persistent logins, and the
human does the login.

## The honest limit on anti-bot detection

A real Chrome profile removes some of the identity signals of automation (that is
the point of attaching to a real browser instead of a managed Chromium). But CDP
leaves **detectable traces**: an enabled `Runtime.enable`, `cdc_` artefacts and more
are visible to Cloudflare, DataDome and similar services. You can check that the
crude flag is absent:
```bash
agent-browser --cdp 9222 eval 'navigator.webdriver'   # expected false/undefined
```
but that does not make the session invisible to a serious anti-bot system.

**Rule:** do not patch and do not try to evade. If you hit an anti-bot check or a
CAPTCHA, **stop and hand over to the human** (they pass the check by hand in the
same window and then let you continue). Evading detection is not part of the skill's
job.
