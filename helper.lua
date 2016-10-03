-- 通知
function notify(sub, text)
  hs.notify.show('Hammerspoon', (text and sub) or '', text or sub)
end

-- 重载
function reload()
  notify('重新加载')
  hs.reload()
end

util = hs.fnutils

-- 判断是否为外接设备
function isExternalDevice (e)
  return util.contains(conf.externalDevice.productID, e.productID) or util.contains(conf.externalDevice.productName, e.productName)
end

-- 当前时间
function now ()
  return hs.timer.secondsSinceEpoch()
end

-- AppleScript
function AS (val)
  hs.osascript._osascript(val, 'AppleScript')
end

-- delay
function delay (cb, delay)
  hs.timer.doAfter(delay, cb)
end

-- inspect
inspect = hs.inspect
