pathWatcher = hs.pathwatcher.new(hs.configdir, function (files)
  util.find(files, function (file)
    if file:sub(-4) == '.lua' then
      reload()
      return true
    end
  end)
end):start()
