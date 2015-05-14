q = require("qttest")

obj1 = q.Object1()
dyn = qt.dynamic()
qt.connect(obj1, "Signal()", dyn, "TestSlot()")
qt.connect(obj1, "StringSignal(QString)", dyn, "TestStringSlot(QString)")
function dyn:TestSlot()
  print("TestSlot")
end
function dyn:TestStringSlot(str)
  print("TestStringSlot ", str)
  quit()
end
qt.connect(dyn, "Sig()", obj1, "Slot()")
qt.connect(dyn, "SigString(QString)", obj1, "StringSlot(QString)")
dyn:Sig()
dyn:SigString("Test string here")
obj1:raiseSignal()
obj1:raiseStringSignal("Test string here")
