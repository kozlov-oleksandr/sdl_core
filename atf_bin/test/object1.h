#line 83 "test.nw"
#pragma once

#include <QObject>
#include <QDebug>

class TestObject1 : public QObject/*{{{*/
{
  Q_OBJECT
  public:
  TestObject1(QObject *parent)
    : QObject(parent) { }
  ~TestObject1() {
    qDebug() << "TestObject::dtor";
  }
  signals:
  void Signal();
  void StringSignal(QString s);
  public slots:
    void Slot();
    void StringSlot(QString);
  public:
  void raiseSignal();
  void raiseStringSignal(QString s);
};/*}}}*/
