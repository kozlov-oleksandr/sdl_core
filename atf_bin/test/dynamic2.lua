sender = qt.dynamic()
receiver = qt.dynamic()
function receiver:test(s)
  print("d.test(): ", s)
  quit()
end
qt.connect(sender, "signal(QString)", receiver, "test(QString)")

sender:signal("hello")
