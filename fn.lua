local key, sys = hs.eventtap.event.newKeyEvent, function (name)
    hs.eventtap.event.newSystemKeyEvent(name, true):post()
    hs.timer.usleep(101)
  hs.eventtap.event.newSystemKeyEvent(name, false):post()
end
if hs.eventtap.checkKeyboardModifiers().fn then
    print("hello")
end
