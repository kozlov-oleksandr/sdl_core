#! /bin/sh

run_test()
{
  # Usage: run_test <test title> <test name> <timeout>
  echo -n "Running $1..."
  timeout $3s ./interp test/$2.lua > test/out/$2.out 2>&1
  RES=$?
  if [ $RES ] && diff test/out/$2.out test/out/$2.success > /dev/null; then
    echo "OK"
  else
    echo "FAIL. See test/out/$2.out for results"
  fi
}

# Three seconds should be enough
run_test "Dynamic object test" dynamic 3
run_test "Dynamic object test2" dynamic2 3
run_test "Qt Connect test" connect 3
run_test "Network test" network 3

#../interp testbase.lua
#../interp dynamic.lua
