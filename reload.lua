pathWatcher = hs.pathwatcher.new(conf.confFolder, function (files)
  hs.fnutils.find(files, function (file)
    if file:sub(-4) == '.lua' then
      reload()
      return true
    end
  end)
end):start()
