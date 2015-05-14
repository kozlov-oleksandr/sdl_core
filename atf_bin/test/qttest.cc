#line 5 "main.nw"
extern "C" {
#include <lua5.2/lua.h>
#include <lua5.2/lualib.h>
#include <lua5.2/lauxlib.h>
}
#line 17 "test.nw"
#include <QObject>
#include <QDebug>
#include "object1.h"

// Creates a Qt object with a set of various signals/*{{{*/
static int qttest_mkObject1(lua_State *L) {
  qDebug() << "test.Object1 ctor";
  lua_getglobal(L, "interp"); // LuaInterpreter obejct must have been saved in global 'interp'
  QObject * interp = *(static_cast<QObject**>(lua_touserdata(L, -1)));
  QObject **p = static_cast<QObject**>(lua_newuserdata(L, sizeof(QObject*)));
  *p = new TestObject1(interp);
  luaL_getmetatable(L, "test.Object1");
  lua_setmetatable(L, -2);
  return 1;
}/*}}}*/

static int qttest_deleteObject1(lua_State *L) {
  qDebug() << "test.Object1 __gc metamethod";
  TestObject1 *obj = *(static_cast<TestObject1**>(lua_touserdata(L, 1)));
  delete obj;
}

static int qttest_Object1_raiseSignal(lua_State *L) {/*{{{*/
  qDebug() << "test.Object1 raiseSignal";
  TestObject1 *obj = *(static_cast<TestObject1**>(lua_touserdata(L, 1)));
  obj->raiseSignal();
  return 0;
}/*}}}*/

static int qttest_Object1_raiseStringSignal(lua_State *L) {/*{{{*/
  qDebug() << "test.Object1 raiseStringSignal";
  TestObject1 *obj = *(static_cast<TestObject1**>(lua_touserdata(L, 1)));
  QString s = lua_tostring(L, 2);
  obj->raiseStringSignal(s);
  return 0;
}/*}}}*/

extern "C"
int luaopen_qttest(lua_State *L) {/*{{{*/
  // Object1 metatable
  luaL_newmetatable(L, "test.Object1");

  lua_newtable(L);/*{{{*/
  luaL_Reg object1_functions[] =
  {
    { "raiseSignal", &qttest_Object1_raiseSignal },
    { "raiseStringSignal", &qttest_Object1_raiseStringSignal },
    { NULL, NULL }
  };
  luaL_setfuncs(L, object1_functions, 0);/*}}}*/

  lua_setfield(L, -2, "__index");

  lua_pushcfunction(L, qttest_deleteObject1);
  lua_setfield(L, -2, "__gc");

  luaL_Reg qttest_functions[] = {
    { "Object1", qttest_mkObject1 },
    { NULL, NULL }
  };

  luaL_newlib(L, qttest_functions);

  return 1;
}/*}}}*/
