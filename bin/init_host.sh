#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 ip hostname"
    exit 1
fi

ip=$1
host=$2


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/log.sh
. $DIR/utils.sh



fab_options=""


echo
LOG DEBUG "init host $host($ip) ..."
echo

    # ip=$(./nametoip.sh $host)


    pwd=$(get_pwd $host)
    port=$($DIR/getconfig.sh ssh_port)


    if [ -z "$ip" ] || [ -z "$port" ] || [ -z "$pwd" ]; then
        LOG ERROR "get ip,post,pwd of $host failed: ($ip:$post, $pwd)"
        exit 1
    fi

    fab_options="--fabfile=$DIR/../env/fabfile.py --hosts=$ip:$port --password=$pwd"


    # add user, group
    user=$($DIR/getconfig.sh run.user)
    group=$($DIR/getconfig.sh run.group)
    fab_command "add_user_group:user=$user,group=$group"


    # base dir
    dir=$($DIR/getconfig.sh basedir.install)
    fab_command "init_base_dir:dir=$dir,user=$user,group=$group"
    dir=$($DIR/getconfig.sh basedir.log)
    fab_command "init_base_dir:dir=$dir,user=$user,group=$group"
    dir=$($DIR/getconfig.sh basedir.data)
    fab_command "init_base_dir:dir=$dir,user=$user,group=$group"


    # JDK
    jdk_pkg=$($DIR/getconfig.sh package.jdk)
    pkg_dir="$DIR/../packages"
    fab_command "install_jdk_tar:tarpath=$pkg_dir/$jdk_pkg,ver=1.7.0_65"


    # TODO: ntp
    LOG INFO "TODO: add ntpupdate to crontab"


    LOG INFO "SUCCEED: init host $host($ip)"


echo