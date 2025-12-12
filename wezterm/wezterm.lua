local wezterm = require 'wezterm';
local io = require 'io'
local os = require 'os'
local act = wezterm.action

wezterm.on('trigger-vim-with-visible-text', function(window, pane)
  -- Retrieve the current viewport's text.
  --
  -- Note: You could also pass an optional number of lines (eg: 2000) to
  -- retrieve that number of lines starting from the bottom of the viewport.
  local viewport_text = pane:get_lines_as_text(10000)

  -- Create a temporary file to pass to vim
  local name = os.tmpname()
  local f = io.open(name, 'w+')
  f:write(viewport_text)
  f:flush()
  f:close()

  wezterm.log_error(name);
  -- Open a new window running vim and tell it to open the file
  window:perform_action(
    act.SpawnCommandInNewTab {
      args = { 'vim', name, '-c', ':normal G'},
    },
    pane
  )

  -- Wait "enough" time for vim to read the file before we remove it.
  -- The window creation and process spawn are asynchronous wrt. running
  -- this script and are not awaitable, so we just pick a number.
  --
  -- Note: We don't strictly need to remove this file, but it is nice
  -- to avoid cluttering up the temporary directory.
  wezterm.sleep_ms(1000)
  os.remove(name)
end)

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '[Z] '
  end

  local procname = tab.active_pane.foreground_process_name:match("^.+/(.+)$")
	local procsuffix = ""
    if procname ~= nil then
        procsuffix = " $" .. procname
    end

  local index = ''
  if #tabs > 1 then
    index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
  end

  return zoomed .. index .. tab.active_pane.title .. procsuffix
end)

local SOLID_LEFT_ARROW = utf8.char(0xe0b6)
local SOLID_RIGHT_ARROW = utf8.char(0xe0b4)

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local edge_background = '#0b0022'
    local background = '#1b1032'
    local foreground = '#a0a0a0'

    if tab.is_active then
      background = '#14638b'
      foreground = '#e0e0e0'
    elseif hover then
      background = '#3b3052'
      foreground = '#b0b0b0'
    end

    local edge_foreground = background

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    local procname = tab.active_pane.foreground_process_name:match("^.+/(.+)$")
	local procsuffix = ""
    if procname ~= nil then
        procsuffix = " $" .. procname
    end
    -- local title = wezterm.truncate_right(tab.active_pane.title, max_width - 2)
    local title = wezterm.truncate_right(tab.active_pane.title .. procsuffix, max_width - 2)

    return {
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_LEFT_ARROW },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_RIGHT_ARROW },
    }
  end
)

return {
  -- font = wezterm.font("Noto Mono"),
  font = wezterm.font_with_fallback {
	  -- {family='Source Code Pro', weight='Bold'},
	  'Fira Code',
	  'Source Code Pro',
	  'Monospace',
      'DejaVu Sans Mono',
	  'Noto Sans CJK JP',
  },
  --   'Monospace',
  -- font = wezterm.font_with_fallback {
  --   'Monospace',
  --   'Noto Mono',
  --   'DejaVu Sans Mono',
  --   'Ubuntu Mono',
  -- },
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  use_ime = true, -- wezは日本人じゃないのでこれがないとIME動かない
  font_size = 17.0,
  -- 自分の好きなテーマ探す https://wezfurlong.org/wezterm/colorschemes/index.html
  -- color_scheme =  "tokyonight",
  -- color_scheme =  "kanagawabones",
  -- color_scheme =  "OneHalfDark",
  -- color_scheme =  "nord",
  color_scheme = "palenight (Gogh)",
  -- color_scheme = "PaperColorDark (Gogh)",
  --color_scheme = "PaulMillr",
  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,
  use_fancy_tab_bar = false,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  -- exit_behavior = "CloseOnCleanExit",
  tab_bar_at_bottom = true,
  tab_max_width = 32,
  keys = {
    {
      key = 'H',
      mods = 'CTRL',
      action = act.EmitEvent 'trigger-vim-with-visible-text',
    },
    { key = '<', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
    { key = '>', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },
    {
      key = '%',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = '"',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      key = 's',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.PaneSelect
    },
    {
      key = 'LeftArrow',
      mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Left',
    },
    {
      key = 'RightArrow',
      mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Right',
    },
    {
      key = 'UpArrow',
      mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Up',
    },
    {
      key = 'DownArrow',
      mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Down',
    },
    -- activate pane selection mode with the default alphabet (labels are "a", "s", "d", "f" and so on)
    { key = 'o', mods = 'CTRL|ALT', action = act.PaneSelect },
  },
  scrollback_lines = 10000,
  warn_about_missing_glyphs = false,
}
