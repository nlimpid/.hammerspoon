--[[
Layer 0
,-----------------------------------------------------------------------------------------.
|  `  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  0  |  -  |  =  |   BSPC    |
|-----------------------------------------------------------------------------------------|
|   TAB  |  Q  |  W  |  E  |  R  |  T  |  Y  |  U  |  I  |  O  |  P  |  [  |  ]  |    \   |
|-----------------------------------------------------------------------------------------|
|  ESC/LCTL  |  A  |  S  |  D  |  F  |  G  |  H  |  J  |  K  |  L  |  ;  |  '  |          |
|-----------------------------------------------------------------------------------------|
|   LSFT/F13   |  Z  |  X  |  C  |  V  |  B  |  N  |  M  |  ,  |  .  |  /  |              |
|-----------------------------------------------------------------------------------------|
|   |F12/Layer 1| LALT | LGUI |       SPACE/Ctrl-Alt-Cmd          | F19/Layer 2 |         |
`-----------------------------------------------------------------------------------------'
Layer 1
,-----------------------------------------------------------------------------------------.
|     |  F1 |  F2 |  F3 |  F4 |  F5 |  F6 |  F7 |  F8 |  F9 | F10 | F11 | F12 |    Del    |
|-----------------------------------------------------------------------------------------|
|       |       |     |     |     |     |     |     |     |     |     |     |     |       |
|-----------------------------------------------------------------------------------------|
|    LCTL    |  B-  |  B+  | kb- | kb+ | kbT | LEFT| DOWN | UP | RGHT |     |     |       |
|-----------------------------------------------------------------------------------------|
|             |  V-  |  V+  | Mute | Pre | Play | Next |                                  |
|-----------------------------------------------------------------------------------------|
|                                                                                         |
`-----------------------------------------------------------------------------------------'
Layer 2
--]]

local eventtap = hs.eventtap
local stroke = eventtap.keyStroke
local strokes = eventtap.keyStrokes
local event = eventtap.event
local newKeyEvent = event.newKeyEvent
local newSystemKeyEvent = event.newSystemKeyEvent
local types = event.types
local properties = event.properties

function systemKey (name)
  newSystemKeyEvent(name, true):post()
  hs.timer.usleep(101)
  newSystemKeyEvent(name, false):post()
end

local state = {
  isLeftShiftDown = false,

  isSpaceDown = false,
  isSpaceCombo = false,
  skipSpaceTimes = 0,

  isEscDown = false,
  isEscCombo = false,
  skipEscTimes = 0,

  isLeftCtrlDown = false,
  isLeftCtrlCombo = false,

  isRightCmdDown = false,
  isRightCmdCombo = false,
}


eventtapWatcher = hs.eventtap.new({ types.keyDown, types.keyUp, types.flagsChanged }, function(e)
  local keyboardType = e:getProperty(properties.keyboardEventKeyboardType)
  if not (util.contains(conf.enabledKeyboard, keyboardType) and keyboardType) then
    return false
  end
  local eventType = types[e:getType()]
  local char = e:getCharacters()
  local raw = e:getRawEventData()
  local code = raw.CGEventData.keycode
  local flags = e:getFlags()
  local flagsArray = {}
  for k,v in pairs(flags) do
    table.insert(flagsArray, k)
  end
  table.sort(flagsArray)
  flagsStr = inspect(flagsArray)
  local rawFlags = raw.CGEventData.flags
  local rawType = raw.CGEventData.type
  local data = raw.NSEventData.data1
  local rawModifier = raw.NSEventData.modifierFlags
  local rawChar = raw.NSEventData.charactersIgnoringModifiers

  -- debug
  -- print(eventType, char, rawChar, code, flagsStr, rawflags, data, rawType, rawModifier)

  function isLeftShiftDown ()
    return code == 56 and flagsStr == inspect({'shift'})
  end
  function isLeftShiftTap ()
    return code == 56 and flagsStr == inspect({}) and state.isLeftShiftDown
  end

  function isSpaceDown ()
    return code == 49 and eventType == 'keyDown' and util.contains({inspect({}), inspect({'fn'})}, flagsStr) and state.skipSpaceTimes == 0
  end
  function isSpaceUp ()
    return code == 49 and eventType == 'keyUp' and util.contains({inspect({}), inspect({'fn'})}, flagsStr) and state.skipSpaceTimes == 0
  end
  function isSpaceComboDown ()
    return state.isSpaceDown and eventType == 'keyDown' and util.contains({inspect({}), inspect({'fn'})}, flagsStr)
  end
  function isSpaceComboUp ()
    return state.isSpaceCombo and state.isSpaceDown and eventType == 'keyUp' and util.contains({inspect({}), inspect({'fn'})}, flagsStr)
  end

  function isEscDown ()
    return code == 53 and eventType == 'keyDown' and state.skipEscTimes == 0
  end
  function isEscUp ()
    return code == 53 and eventType == 'keyUp' and state.skipEscTimes == 0
  end
  function isEscComboDown ()
    return state.isEscDown and eventType == 'keyDown'
  end
  function isEscComboUp ()
    return state.isEscCombo and state.isEscDown and eventType == 'keyUp'
  end

  function isLeftCtrlDown ()
    return code == 59 and eventType == 'flagsChanged' and flagsStr == inspect({'ctrl'})
  end
  function isLeftCtrlUp ()
    return code == 59 and eventType == 'flagsChanged' and flagsStr == inspect({})
  end
  function isLeftCtrlComboDown ()
    return state.isLeftCtrlDown and eventType == 'keyDown' and flagsStr == inspect({'ctrl'})
  end
  function isLeftCtrlComboUp ()
    return state.isLeftCtrlCombo and state.isLeftCtrlDown and eventType == 'keyUp' and flagsStr == inspect({'ctrl'})
  end

  function isRightCmdDown ()
    return code == 54 and eventType == 'flagsChanged' and flagsStr == inspect({'cmd'})
  end
  function isRightCmdUp ()
    return code == 54 and eventType == 'flagsChanged' and flagsStr == inspect({})
  end
  function isRightCmdComboDown ()
    return state.isRightCmdDown and eventType == 'keyDown' and flagsStr == inspect({'cmd'})
  end
  function isRightCmdComboUp ()
    return state.isRightCmdCombo and state.isRightCmdDown and eventType == 'keyUp' and flagsStr == inspect({'cmd'})
  end

  if false then

  -- esc: hold->ctrl
  -- caps lock 太难搞...我已经放弃了, 升级到 10.12 beta 之后, 可以修改修饰键, 把 caps lock 改为 esc
  elseif isEscDown() then
    state.isEscDown = true
    return true
  elseif isEscUp() then
    state.isEscDown = false
    if state.isEscCombo then
      state.isEscCombo = false
    else
      state.skipEscTimes = 2
      stroke({}, 'escape')
    end
    return true
  elseif isEscComboDown() then
    state.isEscCombo = true
    flagsArray = util.concat(flagsArray, {'ctrl'})
    return true, { newKeyEvent(flagsArray, '', true):setKeyCode(code),  newKeyEvent(flagsArray, '', false):setKeyCode(code)}
  elseif isEscComboUp() then
    return true

  -- left shift: tap->f13
  elseif isLeftShiftDown() then
    state.isLeftShiftDown = true
    return false
  elseif isLeftShiftTap() then
    state.isLeftShiftDown = false
    stroke({}, 'f13')
    return true

  -- space: hold->cmd-ctrl-alt
  elseif isSpaceDown() then
    state.isSpaceDown = true
    return true
  elseif isSpaceUp() then
    state.isSpaceDown = false
    if state.isSpaceCombo then
      state.isSpaceCombo = false
    else
      state.skipSpaceTimes = 2
      stroke({}, 'space')
    end
    return true
  elseif isSpaceComboDown() then
    state.isSpaceCombo = true
    flagsArray = util.concat(flagsArray, {'cmd', 'alt' , 'ctrl'})
    return true, { newKeyEvent(flagsArray, '', true):setKeyCode(code),  newKeyEvent(flagsArray, '', false):setKeyCode(code)}
  elseif isSpaceComboUp() then
    return true

  -- left ctrl: tap->f12, hold->layer 1
  elseif isLeftCtrlDown() then
    state.isLeftCtrlDown = true
    return true
  elseif isLeftCtrlUp() then
    state.isLeftCtrlDown = false
    if state.isLeftCtrlCombo then
      state.isLeftCtrlCombo = false
    else
      stroke({}, 'f12')
    end
    return true
  elseif isLeftCtrlComboDown() then
    state.isLeftCtrlCombo = true
    if false then
    elseif rawChar == '1' then
      stroke({}, 'f1')
    elseif rawChar == '2' then
      stroke({}, 'f2')
    elseif rawChar == '3' then
      stroke({}, 'f3')
    elseif rawChar == '4' then
      stroke({}, 'f4')
    elseif rawChar == '5' then
      stroke({}, 'f5')
    elseif rawChar == '6' then
      stroke({}, 'f6')
    elseif rawChar == '7' then
      stroke({}, 'f7')
    elseif rawChar == '8' then
      stroke({}, 'f8')
    elseif rawChar == '9' then
      stroke({}, 'f9')
    elseif rawChar == '0' then
      stroke({}, 'f10')
    elseif rawChar == '-' then
      stroke({}, 'f11')
    elseif rawChar == '=' then
      stroke({}, 'f12')
    elseif code == 51 then
      return true, { newKeyEvent({'fn'}, '', true):setKeyCode(117),  newKeyEvent({'fn'}, '', false):setKeyCode(117)}
    elseif code == 53 then
      hs.osascript._osascript('tell application "System Events" to key code 59', 'AppleScript')
    elseif rawChar == 'z' then
      systemKey('SOUND_DOWN')
    elseif rawChar == 'x' then
      systemKey('SOUND_UP')
    elseif rawChar == 'c' then
      systemKey('MUTE')
    elseif rawChar == 'v' then
      systemKey('PREVIOUS')
    elseif rawChar == 'b' then
      systemKey('PLAY')
    elseif rawChar == 'n' then
      systemKey('NEXT')
    elseif rawChar == 'a' then
      systemKey('BRIGHTNESS_DOWN')
    elseif rawChar == 's' then
      systemKey('BRIGHTNESS_UP')
    elseif rawChar == 'd' then
      systemKey('ILLUMINATION_DOWN')
    elseif rawChar == 'f' then
      systemKey('ILLUMINATION_UP')
    elseif rawChar == 'g' then
      systemKey('ILLUMINATION_TOGGLE')
    elseif rawChar == 'g' then
      systemKey('ILLUMINATION_TOGGLE')
    elseif rawChar == 'h' then
      stroke({'fn'}, 'left')
    elseif rawChar == 'j' then
      stroke({'fn'}, 'down')
    elseif rawChar == 'k' then
      stroke({'fn'}, 'up')
    elseif rawChar == 'l' then
      stroke({'fn'}, 'right')
    end
    return true
  elseif isLeftCtrlComboUp() then
    return true

  -- right cmd: tap->f19, hold->layer 2
  elseif isRightCmdDown() then
    state.isRightCmdDown = true
    return true
  elseif isRightCmdUp() then
    state.isRightCmdDown = false
    if state.isRightCmdCombo then
      state.isRightCmdCombo = false
    else
      stroke({}, 'f19')
    end
    return true
  elseif isRightCmdComboDown() then
    state.isRightCmdCombo = true
    return true
  elseif isRightCmdComboUp() then
    return true


  end

  if state.skipSpaceTimes > 0 then
    state.skipSpaceTimes = state.skipSpaceTimes - 1
  end
  if state.skipEscTimes > 0 then
    state.skipEscTimes = state.skipEscTimes - 1
  end
  state.isLeftShiftDown = false

  return false
end):start()
