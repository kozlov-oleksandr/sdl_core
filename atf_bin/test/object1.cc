#line 108 "test.nw"
#include "object1.h"

void TestObject1::raiseSignal() {/*{{{*/
  emit Signal();
}

void TestObject1::raiseStringSignal(QString s) {
  emit StringSignal(s);
}

void TestObject1::Slot() {
  qDebug() << "TestObject1::Slot()";
}

void TestObject1::StringSlot(QString s) {
  qDebug() << "TestObject1::StringSlot(" << s << ")";
}/*}}}*/
