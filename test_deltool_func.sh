#!/bin/bash

#set -x

#同じディレクトリにあるテストライブラリシェルの読み込み
. ${0%/*}/shell_test.sh

test_start

func_test 'rmtempdir 2' ne 0

func_test 'rmtempdir /tmp/' ne 0

tempfile=`mktemp`
func_test "rmtempdir $tempfile" ne 0
rm $tempfile

tempdir=`mktemp -d $0.XXXXXXX`
func_test "rmtempdir $tempdir" ne 0
rmdir $tempdir

tempdir=`mktemp -d`
func_test "rmtempdir $tempdir" eq 0
rmdir $tempdir

tempdir=`mktemp -d`
func_test "rmtempdir $tempdir" d $tempdir
rmdir $tempdir

test_finish
