local function toggleAppByBundleID (id, max)
  return function ()
    local app = hs.application.frontmostApplication()
    if app and app:bundleID() == id then
      app:hide()
    else
      hs.application.launchOrFocusByBundleID(id)
      if max then
        win():maximize()
      end
    end
  end
end

for k,v in pairs({
  ['0'] = 'com.fournova.Tower2',
  ['1'] = 'com.googlecode.iterm2',
  -- ['1'] = 'co.zeit.hyperterm',
  ['2'] = 'com.google.Chrome',
  ['3'] = 'com.apple.Safari',
  ['4'] = 'com.tencent.qq',
  [','] = 'com.apple.systempreferences',
  ['.'] = '',
  ['\\'] = reload,
  ['-'] = saveLayout,
  ['='] = restoreLayout,
  ['tab'] = winLoopScreen,
}) do
  if type(v) == 'function' then
    hs.hotkey.bind('cmd-ctrl-alt', k, v)
  elseif #v > 0 then
    hs.hotkey.bind('cmd-ctrl-alt', k, toggleAppByBundleID(v))
    hs.hotkey.bind('cmd-ctrl-alt-shift', k, toggleAppByBundleID(v, true))
  end
end
