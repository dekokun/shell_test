#!/bin/bash

#同じディレクトリにあるテストライブラリシェルの読み込み
. ${0%/*}/../shell_test.sh

test_start

func_test "test_start" eq 0
func_test "func_test" ne 0
func_test "func_test ls  eq 0" eq 0
func_test "func_test false" ne 0


test_finish
