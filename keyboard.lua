function unloadKeyboad()
  AS('do shell script "echo '..conf.pwd.os..' | sudo -S kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/"')
  notify('内置键盘', '禁用')
end
function loadKeyboad(slient)
  AS('do shell script "echo '..conf.pwd.os..' | sudo -S kextload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/"')
  if not slient then
    notify('内置键盘', '启用')
  end
end

usbWatcher = hs.usb.watcher.new(function (e)
  if isExternalDevice(e) then
    if e.eventType == 'added' then
      unloadKeyboad()
    elseif e.eventType == 'removed' then
      loadKeyboad()
    end
  end
end):start()

function checkKeyboad ()
  for k, v in pairs(hs.usb.attachedDevices()) do
    if isExternalDevice(v) then
      unloadKeyboad()
      return
    end
  end
  loadKeyboad(true)
end

checkKeyboad()
