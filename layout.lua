layout = {}
hs.window.animationDuration = 0
-- hs.window.setFrameCorrectness = true
function win ()
  return hs.window.frontmostWindow()
end
function winHalfLeft() win():move(hs.layout.left50) end
function winCenter() win():move('[25,25,75,75]') end
function winMax () win():maximize() end
function winRightHalf() win():move(hs.layout.right50) end
function winLoopScreen()
  local win = win()
  win:moveToScreen(win:screen():next(), true, true)
end
function saveLayout ()
  notify('布局', '保存')
  layout = {}
  for i,v in ipairs(hs.window.filter.default:getWindows()) do
    layout[v:title()] = {
      frame = v:frame(),
      isPrimaryScreen = v:screen():id() == hs.screen.primaryScreen():id(),
    }
  end

end
function restoreLayout ()
  notify('布局', '恢复')
  for i,v in ipairs(hs.window.filter.default:getWindows()) do
    local item = layout[v:title()]
    if item then
      local frame = item.frame
      local primaryScreen = hs.screen.primaryScreen()
      v:move(frame, (item.isPrimaryScreen and primaryScreen) or primaryScreen:next())
    end
  end
end
caffeinateWatcher = hs.caffeinate.watcher.new(function(e)
  -- 5, lock; 6, unlock;
  -- sleep display: 3, 10; 4, 11
  -- sleep: 3, 10, 0, 4, 11
  -- print(hs.timer.localTime(), e)
  if e == hs.caffeinate.watcher.screensDidUnlock then
    restoreLayout()
  end
  if e == hs.caffeinate.watcher.screensDidSleep then
    saveLayout()
  end
end):start()
