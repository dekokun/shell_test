#!/bin/bash

#テスト前の初期化スクリプト
#テストファイルで一度だけ呼ぶこと
#テストファイルの名前を見て読み込むファイルを設定
test_start(){
    #テストファイルの拡張子含めたファイル名(パス含まず)を取得
    local file_name=${0##*/}
    #読み込むためのテスト対象ファイル名を取得
    local source_file_name=`color_echo $file_name | cut -d'_' -f2-`
    #テストファイルのファイル名を除いたパスを取得
    local path=${0%/*}
    local source_file=$path/../$source_file_name
    if [ -f $source_file ]
    then
        . $source_file
    else
        color_echo red "source file $source_file not found"
        color_echo red "このファイルの親ディレクトリに、このファイル名からtest_を除いた名前のファイルがある必要があります。"
        exit 1
    fi
    test_count=0
    success_count=0
    failed_count=0
}

#todo 副作用のあるテストは分けるべき?
func_test(){
    local test_command=$1
    local compare_word=$2
    local expected_return=$3
    local compare_word_count=${#compare_word}
    test_count=`expr $test_count + 1`
    #引数が3個以下だったらアラートを出力しテスト終了
    if [ $# -lt 2 ]
    then
        color_echo usage: $0 \"function_name with parameter\" compare_parameter expected_return
        color_echo ex.\) func_test \"rmtempdir /tmp/test\" eq 0
        return 1
    fi

    local std_out
    #テスト実行(標準出力は格納)
    std_out=`$test_command`

    local func_result=$?
    local for_test_command
    local test_result_word

    #シェルスクリプトでは関数は数字しか返さないので=や-nなどは無意味かと思えるが、副作用のテストに使用できる(ファイルができたかなど。ただしその場合も=は必要ないか?)
    if [ "$compare_word" = "=" ]
    then
        for_test_command="$func_result = $expected_return"
    elif [ $compare_word_count -eq 2 ]
    then
        for_test_command="$func_result -$compare_word $expected_return"
    elif [ $compare_word_count -eq 1 ]
    then
        for_test_command="-$compare_word $expected_return"
    fi

    local color
    if [ $for_test_command ]
    then
        success_count=`expr $success_count + 1`
        test_result_word="success"
        color="green"
    else
        failed_count=`expr $failed_count + 1`
        test_result_word="faild"
        color="red"
    fi
    color_echo --------------------------------
    color_echo $color "標準出力:"$std_out
    color_echo $color test count: $test_count
    color_echo $color test: "\"$test_command\"" "should" $compare_word $expected_return
    color_echo $color function result: $func_result
    color_echo $color test result: $test_result_word
    color_echo --------------------------------
    color_echo

    return 0
}

test_func(){
    func_test $@
}

test_finish(){
    local color
    local last_message
    if [ $success_count -eq $test_count ]
    then
        last_message="All success"
        color="green"
    else
        echo "通らない"
        last_message="Test failed"
        color="red"
    fi

    color_echo --------------------------------
    color_echo $color success count: $success_count
    color_echo $color failed count : $failed_count
    color_echo $color $last_message
    color_echo --------------------------------
}

#第一引数が'red'もしくは'green'だったらその色の出力をする
#それ以外の場合はdefault色を指定
color_echo(){
    local green=$'\e[0;32m'
    local red=$'\e[0;31m'
    local default=$'\e[m'
    local for_count=1
    local color=$default

    echo -n $default

    for arg in $@
    do
        if [ $for_count -eq 1 ]
        then
            if [ $arg = 'green' ]
            then
                echo -n $green
            elif [ $arg = 'red' ]
            then
                echo -n $red
            elif [ $arg = 'default' ]
            then
                echo -n $default
            else
                echo -n $default
                echo -n $arg
            fi
        else
            echo -n "$arg "
        fi
        for_count=`expr $for_count + 1`
    done

    echo
    #その後のechoに影響を与えないためにdefaultに戻す
    echo -n $default
    return 0
}
