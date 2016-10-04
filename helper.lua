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
  return hs.osascript.applescript(val)
end
function SH (val)
  return AS('set result to do shell script "'..val..'"')
end

function getSystemPwd ()
  local succeeded, result = SH('security find-generic-password -s hammerspoon -a system -w')
  return result
end

-- delay
function delay (cb, delay)
  hs.timer.doAfter(delay, cb)
end

-- inspect
inspect = hs.inspect

-- deepEqual
function isEqual (a, b)
  util.sortByKeys(a)
  util.sortByKeys(b)
  return inspect(a) == inspect(b)
end

-- debug
function put (...)
  if conf.debug then
    print(...)
  end
end

-- includes
function includes (list, item)
  for i=1,#list+1 do
    if item == list[i] then
      return true
    end
  end
  return false
end
