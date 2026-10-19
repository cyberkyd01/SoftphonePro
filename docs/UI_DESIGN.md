# SoftphonePro — UI/UX Design Spec

The app should feel calm, professional and fast, like a well-made business
tool rather than a toy. It follows Material 3 conventions, with a quieter and
denser desktop variant.

## Brand and tokens
* Primary is **Indigo 600 `#3F51E0`**. Generate the scheme with
  `ColorScheme.fromSeed`, then override `primary`.
* Fixed semantic colours, the same in both themes:
  * call/answer green `#16A34A`
  * end/decline red `#DC2626`
  * hold amber `#D97706`
  * registered green `#22C55E`, registering amber `#F59E0B`, failed red
    `#EF4444`, disabled grey `#9CA3AF`
* Surfaces:
  * light: `#F7F8FA` background, `#FFFFFF` cards
  * dark: `#0F1115` background, `#171A21` cards, `#232733` raised
* Shape: 12 px radius for cards and inputs, 24 px for sheets, circles for
  call buttons.
* Spacing uses a 4 px base: 8, 12, 16, 24, 32.
* Typography is **Inter** (bundled under `app/assets/fonts`, OFL licence),
  falling back to the platform font.
  * Display numbers (dialer field, call timer) use tabular figures
    (`FontFeature.tabularFigures()`).
* Icons are Flutter's built-in Material Icons, rounded variants
  (`Icons.call_rounded`, ...).
* Motion lasts 150–250 ms with `Curves.easeOutCubic`. No gratuitous animation.
  The incoming call gets a gentle pulse ring around the avatar.

## Layout
**Breakpoints:**
* compact: under 600
* medium: 600–839
* expanded: 840 and up, which is the desktop layout

**Mobile (compact / medium):**
* Bottom `NavigationBar` with Keypad · Recents · Contacts · Messages · More.
  More holds LAN, Voicemail, Settings and Diagnostics.
* Below the app bar sits an **account strip**: horizontally scrollable chips,
  each with a status dot and the account name. Tapping a chip opens the
  account sheet.
* While a call is active, a persistent **call bar** (green, tappable) shows
  above the navigation bar whenever the in-call screen isn't in front.
* The in-call screen is full-screen:
  * Top: name, number, account, timer.
  * Middle: quality bars, plus a lock icon when the call is secure.
  * Below: a large avatar, then a 3×3 action grid — Mute, Keypad, Speaker,
    Hold, Add call, Transfer, Record, Merge, More.
  * Bottom: a large red end button.
  * Multiple calls show as stacked cards with Swap and Merge.
* Incoming calls get a full-screen route with Answer, Decline and swipe
  actions. The secondary actions are "Reply with message", "Send to
  voicemail (redirect)" and "Transfer to LAN device".

**Desktop (expanded):**
* Left `NavigationRail`, extended with labels at 1200 px and wider.
  * Top: the logo.
  * Destinations: Keypad, Recents, Contacts, Messages, BLF/Presence, LAN,
    Settings.
  * Bottom: the user's global status (Available, Away, DND).
* Top bar: global search (contacts, history, numbers) and account status
  chips, plus a voicemail badge with count.
* The content pane is the selected page.
* **Right panel (360 px)** holds the active calls. Each card shows avatar,
  name, timer, state and inline controls. The panel collapses when there
  are no calls.
* Incoming call: an in-app banner card at the top-right with Answer and
  Decline, plus a system notification. The tray icon flashes.
* Keypad page:
  * A centred card holds the number field, the account selector (a dropdown
    with status dots) and the keypad.
  * A suggestions list on the right fills from T9 matches against contacts
    and history.
  * Under the call button: a "Call from <account>" hint.
* Settings is a two-pane master/detail layout.

## Key components (`lib/ui/widgets/`)
* `StatusDot`, `AccountChip` (with the reason on hover)
* `Avatar`: initials on a hashed colour, a presence ring in BLF colours
  (idle green, ringing amber pulsing, busy red)
* `DialPad`:
  * buttons with digit plus letters
  * long-press 0 for +, long-press 1 for voicemail
  * hardware keyboard input on desktop, DTMF tones on press
* `CallActionButton`: a circular toggle with a label
* `QualityIndicator`: 0–5 bars from MOS, with a tooltip of the stats
* `SecureBadge`
* `EmptyState`: icon, title, subtitle and an action
* `SectionHeader`, `SettingsTile` variants (switch, select, text, slider)

## Interaction rules
* Every destructive action, such as deleting an account or clearing history,
  asks for confirmation. Hanging up does not.
* Errors are human-readable, such as "Wrong password (403)". Each one offers
  a **Details** button that shows the SIP code and reason, and a link to the
  SIP trace.
* Empty states always offer the next step, such as "Add your first account".
* Desktop shortcuts:
  * Ctrl/Cmd+K: search
  * Ctrl/Cmd+D: focus the dialer
  * Enter: call the focused number
  * Ctrl/Cmd+M: mute
  * Ctrl/Cmd+Shift+H: hold
  * Ctrl/Cmd+Shift+T: transfer
  * Ctrl/Cmd+E: end call
  * Ctrl/Cmd+Shift+A: answer
  * Ctrl/Cmd+,: settings
* Accessibility:
  * All controls have semantic labels and tooltips.
  * Hit targets are at least 44 px on mobile.
  * Contrast meets WCAG AA in both themes.
  * Large text up to 200% must not break layouts.
