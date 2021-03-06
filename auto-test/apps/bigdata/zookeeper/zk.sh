#!/bin/bash

#=================================================================
#   文件名称：zk.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月23日
#   描    述：
#
#================================================================*/


function zk_install_standalone(){
    
    yum install -y ansible
    yum insatll -y python2-pip 
    yum install -y nmap-ncat

    ansible-playbook -i ./zk/hosts ./zk/site.yml -t install 
    ret=$?
    print_info $ret "zookeeper_standalone_install" 
    if [ $ret -ne 0 ];then
        echo 
        echo "zookeeper install error"
        echo 
        exit 1
    fi 

}

function zk_start(){
    
    ansible-playbook -i ./zk/hosts ./zk/site.yml -t start 
    ret=$?
    print_info $ret "zookeeper_start"
    if [ $ret -ne 0 ];then
        echo 
        echo "zookeeper start error"
        echo
        exit 1
    fi 
}

function zk_stop(){
    
    ansible-playbook -i ./zk/hosts ./zk/site.yml -t stop 
    ret=$?
    print_info $ret "zookeeper_stop"
    if [ $ret -ne 0 ];then
        echo
        echo "zookeeper stop error"
        echo
    fi 

}

function zk_install_c_client(){
    
    if [ -z $ZK_HOME ];then
       export  ZK_HOME=/var/bigdata/zookeeper/zookeeper*
    fi 
    pushd .
        cd $ZK_HOME
        cd ./src/c
        ./configure && \
        make && \
        make install 
        ret=$?
        print_info $ret "zookeeper_install_c_client"
        
    popd 
    if [ $ret -eq 0 ];then
       pip install zkpython
       ret=$?
       print_info $ret "zookeeper_install_zkpython"
    fi
    return $ret     
}


function zk_base_operoter(){
    
    $ZK_HOME/bin/zkSever.sh status | grep standalone
    print_info $? "zookeeper_status_ok"
    
    $ZK_HOME/bin/zkCli.sh create /test "this is test data" | grep -v INFO
    $ZK_HOME/bin/zkCli.sh ls | grep -v INFO | grep test 
    print_info $? "zookeeper_create_znode"

    $ZK_HOME/bin/zkCli.sh set /test "this is test data" | grep -v INFO 
    print_info $? "zookeeper_set_znode_data" 

    $ZK_HOME/bin/zkCli.sh get /test | grep "this is test data" | grep -v INFO 
    print_info $? "zookeeper_get_znode_data"
    
    ret=$ZK_HOME/bin/zkCli.sh ls / | egrep -c "test|zookeeper" | grep -v INFO 
    if [ $ret -eq 2 ];then
        true
    else
        false
    fi
    print_info $? "zookeeper_ls_znode"

    $ZK_HOME/bin/zkCli.sh stat /test  | grep -v INFO 
    print_info $? "zookeeper_stat_znode"

    $ZK_HOME/bin/zkCli.sh create /test/a "tmp data" | grep -v INFO 
    $ZK_HOME/bin/zkCli.sh delete /test/a | grep -v INFO 
    print_info $? "zookeeper_delete_znode"

    $ZK_HOME/bin/zkCli.sh rmr /test | grep -v INFO 
    print_info $? "zookeeper_rmr_znode"

}



function zk_admin_test(){

    echo cons | nc localhost 2181
    print_info $? "zookeeper_conntions_info"

    echo crst | nc localhost 2181
    print_info $? "zookeeper_reset_conntion"

    echo dump | nc localhost 2181
    print_info $? "zookeeper_dump_Lists_the_outstanding_sessions_and_ephemeral_nodes"

    echo envi | nc localhost 2181
    print_info $? "zookeeper_envi_server_environment"

    echo ruok | nc localhost 2181 | grep imok
    print_info $? "zookeeper_rock_test_server_state"

    
    echo srst | nc localhost 2181
    print_info $? "zookeeper_srst_reset_server_statistis"

    
    echo srvr | nc localhost 2181
    print_info $? "zookeeper_srvr_list_full_server_info"

    echo stat | nc localhost 2181
    print_info $? "zookeeper_stat_list_brief_server_info"
    echo wchs | nc localhost 2181
    print_info $? "zookeeper_wchs_list_watch_info"
    echo wchc | nc localhost 2181
    print_info $? "zookeeper_wchc_list_watch_info_by_session"
    echo wchp | nc localhost 2181
    print_info $? "zookeeper_wchp_list_watch_info_by_path"
    echo mntr | nc localhost 2181
    print_info $? "zookeeper_mntr_list_var_montit_server_health"
}


