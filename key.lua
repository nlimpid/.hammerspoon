--[[
取 Apple 键盘和 60% 键盘想同的部分作为基础
,-----------------------------------------------------------------------------------------.
|  `  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  0  |  -  |  =  |   BSPC    |
|-----------------------------------------------------------------------------------------|
|   TAB  |  Q  |  W  |  E  |  R  |  T  |  Y  |  U  |  I  |  O  |  P  |  [  |  ]  |    \   |
|-----------------------------------------------------------------------------------------|
|    CAPS    |  A  |  S  |  D  |  F  |  G  |  H  |  J  |  K  |  L  |  ;  |  '  |          |
|-----------------------------------------------------------------------------------------|
|    LSFT     |  Z  |  X  |  C  |  V  |  B  |  N  |  M  |  ,  |  .  |  /  |      UP       |
|-----------------------------------------------------------------------------------------|
|     | LCTL | LALT | LGUI |              SPACE                     | RGUI |LEFT|DOWN|RGHT|
`-----------------------------------------------------------------------------------------'
Layer 0(默认层)
,-----------------------------------------------------------------------------------------.
|     |     |     |     |     |     |     |     |     |     |     |     |     |           |
|-----------------------------------------------------------------------------------------|
|        |     |     |     |     |     |     |     |     |     |     |     |     |        |
|-----------------------------------------------------------------------------------------|
|   LCTL/ESC |     |     |     |     |     |     |     |     |     |     |     |          |
|-----------------------------------------------------------------------------------------|
|   LSFT/F13   |     |     |     |     |     |     |     |     |     |     |              |
|-----------------------------------------------------------------------------------------|
|     | F12/Layer 1 |     |     |    SPACE/LCTL-LALTL-LGUI     |F19|    |DOWN/Layer 2|    |
`-----------------------------------------------------------------------------------------'
Layer 1
,-----------------------------------------------------------------------------------------.
|     |  F1 |  F2 |  F3 |  F4 |  F5 |  F6 |  F7 |  F8 |  F9 | F10 | F11 | F12 |    Del    |
|-----------------------------------------------------------------------------------------|
|       |       |     |     |     |     |     |     |     |     |     |     |     |       |
|-----------------------------------------------------------------------------------------|
|            |  B-  |  B+  | KB- | KB+ | KBT | LEFT| DOWN | UP | RGHT |     |     |       |
|-----------------------------------------------------------------------------------------|
|             |  V-  |  V+  | MUTE | MPRV | MPLY | MNXT |                                 |
|-----------------------------------------------------------------------------------------|
|                                                                                         |
`-----------------------------------------------------------------------------------------'
Layer 2
,-----------------------------------------------------------------------------------------.
|     |     |     |     |     |     |     |     |     |     |     |     |     |           |
|-----------------------------------------------------------------------------------------|
|        |     |     |     |     |     |     |     |     |     |     |     |     |        |
|-----------------------------------------------------------------------------------------|
|            |     |     |     |     |     |     |     |     |     |     |     |          |
|-----------------------------------------------------------------------------------------|
|              |     |     |     |     |     |     |     |     |     |     |              |
|-----------------------------------------------------------------------------------------|
|     |       |      |      |                                       |      |    |    |    |
`-----------------------------------------------------------------------------------------'
--]]

local press, text = hs.eventtap.keyStroke, hs.eventtap.keyStrokes
local key, sys = hs.eventtap.event.newKeyEvent, function (name)
  hs.eventtap.event.newSystemKeyEvent(name, true):post()
  hs.timer.usleep(101)
  hs.eventtap.event.newSystemKeyEvent(name, false):post()
end
local types = hs.eventtap.event.types
local codes = hs.keycodes.map
codes.leftShift = 56
codes.leftCtrl = 59
codes.rightCmd = 54

local state = {
  startTime = now(),
}

eventtapWatcher = hs.eventtap.new({ types.keyDown, types.keyUp, types.flagsChanged, types.NSSystemDefined }, function(e)
  local keyboardType = e:getProperty(hs.eventtap.event.properties.keyboardEventKeyboardType)
  local raw = e:getRawEventData()
  local data = raw.NSEventData.data1
  if not util.contains({264960, 264704}, data) and (not keyboardType or not util.contains(conf.enabledKeyboard, keyboardType)) then
    return false
  end
  local eType, code, flagsTable = e:getType(), e:getKeyCode(), e:getFlags()
  local char = raw.NSEventData.charactersIgnoringModifiers
  local rawChar = raw.NSEventData.characters
  local flagsArray = {}
  for k,v in pairs(flagsTable) do
    table.insert(flagsArray, k)
  end
  table.sort(flagsArray)
  flags = table.concat(flagsArray, '-')

  -- debug
  put(string.format("%.4f", now()-state.startTime), char, rawChar, code, flags, types[eType], data)

  function isKey (codeOrName, flagsStrOrArray, eventType, dataVal)
    if codeOrName then
      if type(codeOrName) == 'number' then
        if codeOrName ~= code then
          return
        end
      elseif codes[codeOrName] ~= code then
        return
      end
    end
    if eventType then
      if type(eventType) == 'table' then
        if not util.find(eventType, function (i)
          return types[i] == eType
        end) then
          return
        end
      elseif types[eventType] ~= eType then
        return
      end
    end
    if flagsStrOrArray then
      if type(flagsStrOrArray) == 'string' then
        if flagsStrOrArray ~= flags then
          return
        end
      else
        if not util.contains(flagsStrOrArray, flags) then
          return
        end
      end
    end
    if dataVal then
      if dataVal ~= data then
        return false
      end
    end
    return true
  end
  if nil then
  elseif isKey('space', '', 'keyDown') and includes({0, nil}, state.skipSpaceTimes) then -- SPACE/LCTL-LALTL-LGUI
    state.spaceDown = true
    return true
  elseif isKey('space', '', 'keyUp') and includes({0, nil}, state.skipSpaceTimes) then
    state.spaceDown = false
    if state.spaceCombo then
      state.spaceCombo = false
    else
      state.skipSpaceTimes = 2
      press({}, 'space')
    end
    return true
  elseif isKey(nil, nil, 'keyDown') and state.spaceDown then
    state.spaceCombo = true
    util.concat(flagsArray, {'cmd', 'alt' , 'ctrl'})
    return true, { key(flagsArray, '', true):setKeyCode(code), key(flagsArray, '', false):setKeyCode(code) }
  elseif isKey(nil, nil, 'keyUp') and state.spaceDown and state.spaceCombo then
    return true
  elseif isKey(nil, nil, 'NSSystemDefined', 264704) then -- CAPS: LCTL/ESC
    hs.task.new(hs.configdir..'/led', function() end):start()
    state.capsDown = true
    return true
  elseif isKey(nil, nil, 'NSSystemDefined', 264960) then
    state.capsDown = false
    if state.capsCombo then
      state.capsCombo = false
    else
      press({}, 'escape')
    end
    return true
  elseif isKey(nil, nil, 'keyDown') and state.capsDown then
    state.capsCombo = true
    util.concat(flagsArray, {'ctrl'})
    return true, { key(flagsArray, '', true):setKeyCode(code), key(flagsArray, '', false):setKeyCode(code) }
  elseif isKey(nil, nil, 'keyUp') and state.capsDown then
    return true
  -- elseif isKey('escape', nil, 'keyDown') and includes({0, nil}, state.skipEscTimes) then -- ESC: LCTL/ESC(os >= 10.12.1 时, 可设置 CAPS->ESC)
  --   state.escDown = true
  --   return true
  -- elseif isKey('escape', nil, 'keyUp') and includes({0, nil}, state.skipEscTimes) then
  --   state.escDown = false
  --   if state.escCombo then
  --     state.escCombo = false
  --   else
  --     state.skipEscTimes = 2
  --     press({}, 'escape')
  --   end
  --   return true
  -- elseif isKey(nil, nil, 'keyDown') and state.escDown then
  --   state.escCombo = true
  --   util.concat(flagsArray, {'ctrl'})
  --   return true, { key(flagsArray, '', true):setKeyCode(code), key(flagsArray, '', false):setKeyCode(code) }
  -- elseif isKey(nil, nil, 'keyUp') and state.escDown then
  --   return true
  elseif isKey('leftShift', 'shift', 'flagsChanged') then -- LSFT: LSFT/F13
    state.leftShiftDown = true
    return true
  elseif isKey('leftShift', '', 'flagsChanged') then
    if state.leftShiftDown then
      state.leftShiftDown = false
      press({}, 'f13')
      -- switchInput()
    end
  elseif isKey('rightCmd', 'cmd', 'flagsChanged') then -- RGUI: F19
    state.rightCmdDown = true
    return true
  elseif isKey('rightCmd', '', 'flagsChanged') then
    if state.rightCmdDown then
      state.rightCmdDown = false
      press({}, 'f19')
    end
  elseif isKey('leftCtrl', 'ctrl', 'flagsChanged') then -- LCTL: F12/Layer 1
    state.leftCtrlDown = true
    return true
  elseif isKey('leftCtrl', '', 'flagsChanged') and state.leftCtrlDown then
    state.leftCtrlDown = false
    if state.leftCtrlCombo then
      state.leftCtrlCombo = false
    else
      press({}, 'f12')
    end
    return true
  elseif isKey(nil, 'ctrl', 'keyDown') and state.leftCtrlDown then
    state.leftCtrlCombo = true
    if false then
    elseif isKey('1') then
      press({}, 'f1')
    elseif isKey('2') then
      press({}, 'f2')
    elseif isKey('3') then
      press({}, 'f3')
    elseif isKey('4') then
      press({}, 'f4')
    elseif isKey('5') then
      press({}, 'f5')
    elseif isKey('6') then
      press({}, 'f6')
    elseif isKey('7') then
      press({}, 'f7')
    elseif isKey('8') then
      press({}, 'f8')
    elseif isKey('9') then
      press({}, 'f9')
    elseif isKey('0') then
      press({}, 'f10')
    elseif isKey('-') then
      press({}, 'f11')
    elseif isKey('=') then
      press({}, 'f12')
    elseif isKey('delete') then
      press({}, 'forwarddelete')
    elseif isKey('z') then
      sys('SOUND_DOWN')
    elseif isKey('x') then
      sys('SOUND_UP')
    elseif isKey('c') then
      sys('MUTE')
    elseif isKey('v') then
      sys('PREVIOUS')
    elseif isKey('b') then
      sys('PLAY')
    elseif isKey('n') then
      sys('NEXT')
    elseif isKey('a') then
      sys('BRIGHTNESS_DOWN')
    elseif isKey('s') then
      sys('BRIGHTNESS_UP')
    elseif isKey('d') then
      sys('ILLUMINATION_DOWN')
    elseif isKey('f') then
      sys('ILLUMINATION_UP')
    elseif isKey('g') then
      sys('ILLUMINATION_TOGGLE')
    elseif isKey('g') then
      sys('ILLUMINATION_TOGGLE')
    elseif isKey('h') then
      press({'fn'}, 'left')
    elseif isKey('j') then
      press({'fn'}, 'down')
    elseif isKey('k') then
      press({'fn'}, 'up')
    elseif isKey('l') then
      press({'fn'}, 'right')
    else
      flagsArray = hs.fnutils.filter(flagsArray, function(i) return i ~= 'ctrl' end)
      return true, { key(flagsArray, '', true):setKeyCode(code), key(flagsArray, '', false):setKeyCode(code) }
    end
    return true
  elseif isKey(nil, 'ctrl', 'keyUp') and state.leftCtrlDown and state.leftCtrlCombo then
    return true
  elseif isKey('down', 'fn', 'keyDown') and includes({0, nil}, state.skipDownTimes) then -- DOWN: DOWN/Layer 2
    state.downDown = true
    return true
  elseif isKey('down', 'fn', 'keyUp') and state.downDown and includes({0, nil}, state.skipDownTimes) then
    state.downDown = false
    if state.downCombo then
      state.downCombo = false
    else
      state.skipDownTimes = 2
      press({}, 'down')
    end
    return true
  elseif isKey(nil, '', 'keyDown') and state.downDown then
    state.downCombo = true
    return true
  elseif isKey(nil, '', 'keyUp') and state.downDown and state.downCombo then
    return true
  elseif char and rawChar and string.match(char, '%l+') and string.match(rawChar, '%u+') then
    return true, { key(flagsArray, char, eType == types.keyDown) }
  end
  if state.skipSpaceTimes and state.skipSpaceTimes > 0 then
    state.skipSpaceTimes = state.skipSpaceTimes - 1
  end
  if state.skipEscTimes and state.skipEscTimes > 0 then
    state.skipEscTimes = state.skipEscTimes - 1
  end
  if state.skipDownTimes and state.skipDownTimes > 0 then
    state.skipDownTimes = state.skipDownTimes - 1
  end
  state.leftShiftDown = false
  return
end):start()
