# svn用の設定
export SSH_USER=s-fujii
export SVN_SSH="ssh -l s-fujii"

#euslisp
export PATH=$PATH:`rospack find roseus`/bin

#euslib
export CVSDIR=~/prog
#source $(rospack find euslisp)/jskeus/bashrc.eus

# rviz
export OGRE_RTT_MODE=Copy  # ノートPCの人は

# openrtm (openrtmのmakeを通す必要がある???)
#export RTCTREE_NAMESERVERS=localhost
#export PATH=$PATH:`rospack find openrtm`/bin
#export PYTHONPATH=$PYTHONPATH:`rospack find openrtm`/src/openrtm

#roar
## pytave
export PYTHONPATH=$PYTHONPATH:$HOME/softwares/pytave/lib/python/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/softwares/pytave
## shogun
#export PYTHONPATH=$PYTHONPATH:$HOME/softwares/shogun/
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/softwares/shogun/lib

# 以下はrosmake openrtm --rosdep-install をすると生成されるはず
#source `rospack find openrtm_tools`/share/rtshell/shell_support
#source `rospack find openrtm_tools`/scripts/rtshell-setup.sh

function rossetpr1040() {
    rossetrobot pr1040
}
function rossetpr1012() {
    rossetrobot pr1012
}
function rossetrobot() {
    local hostname=${1-"pr1040"}
    local ros_port=${2-"11311"}
    export ROS_MASTER_URI=http://$hostname:$ros_port
    echo -e "\e[1;31mset ROS_MASTER_URI to $ROS_MASTER_URI\e[m"
    rossetip
}
function rossetlocal() {
    export ROS_MASTER_URI=http://localhost:11311
    echo -e "\e[1;31mset ROS_MASTER_URI to $ROS_MASTER_URI\e[m"
}
function rossetip() {
  export ROS_IP=`LANG=C ifconfig|egrep -A1 '(wlan0|eth0)'|grep 'inet addr'|sed -e 's/.*inet addr:\([0-9\.]*\).*/\1/g'|head -1`
  export ROS_HOSTNAME=$ROS_IP
  echo -e "\e[1;31mset ROS_IP and ROS_HOSTNAME to $ROS_IP\e[m"
}

# for hrp2user
export OPENHRPHOME=$CVSDIR/OpenHRP
export ROBOT=HRP2JSKNT # 自分の使うHRP2に応じて適宜変更
export HRP2NO=16 # 自分の使うHRP2に応じて適宜変更

#export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$CVSDIR/jsk-ros-pkg-unreleased

function rossethrp2017() {
    rossetrobot hrp2017v 10017
    export ROBOT=HRP2JSKNTS
    export HRP2NO=17
}

function rossethrp2016() {
    rossetrobot hrp2016v 10016
    export ROBOT=HRP2JSKNT
    export HRP2NO=16
}
#export ROS_PACKAGE_PATH=$HOME/src/hark-srcs/hark-ros-stacks-fuerte-1.1.1:$HOME/prog/euslib/demo/s-fujii/sifi-ros-pkgs:$HOME/workarea/roswork:$ROS_PACKAGE_PATH
export ROS_PACKAGE_PATH=$HOME/ros/groovy/my-ros-pkgs:$ROS_PACKAGE_PATH

#rosruby
#export RUBYLIB=`rospack find rosruby`/lib

# load drcsim
#local ROS_PACKAGE_PATH_ORG=$ROS_PACKAGE_PATH
#source /usr/share/drcsim/setup.sh
#ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH_ORG:$ROS_PACKAGE_PATH
#export ROS_PACKAGE_PATH=`echo $(echo $ROS_PACKAGE_PATH | sed -e "s/:/\n/g" | awk '!($0 in A) && A[$0] = 1' | grep -v "opt/ros"; echo $ROS_PACKAGE_PATH | sed -e "s/:/\n/g" | awk '!($0 in A) && A[$0] = 1' | grep "opt/ros") | sed -e "s/ /:/g"`

function roslaunch(){ command optirun roslaunch $@ }
function rosrun(){ command optirun rosrun $@ }
function rospython ()
{
    if [[ -z $1 ]]; then
        if [[ -f ./manifest.xml ]]; then
            pkgname=`basename \`pwd\``;
            ipython -i -c "import roslib; roslib.load_manifest('$pkgname')";
        else
            ipython;
        fi;
    else
        ipython -i -c "import roslib; roslib.load_manifest('$1')";
    fi
}
alias veus="vim -c 'VimShellInteractive roseus' -c 'only'"
