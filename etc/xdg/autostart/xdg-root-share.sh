#!/usr/bin/env bash 

# ref：
# From: Alan Mackenzie <acm@muc.de>
# Newsgroups: comp.unix.shell
# Subject: How do I convert a filename to absolute in bash?
# 改为下面的实现：

# 进一步发现了下面的方法：
# 得到shell脚本文件所在完整路径（绝对路径）及文件名（无论source,bash,.三种调用方式），
# 且不改变shell的当前目录。

# ref：
# https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
# 上文中谈到：
# if you call it from a "source ../../yourScript", $0 would be "bash"!
# 
# 故基于 $0 实现的方法，对于 使用 source 命令的时候会失效。
# ref：
# From: Hongyi Zhao <hongyi.zhao@gmail.com>
# Newsgroups: comp.unix.shell
# Subject: Cann't obtain the script's directory from within sript itself by
#  uisng the . command.

# 参考下面的出错信息：
# werner@debian-01:~$ realpath -e -- bash
# realpath: bash: No such file or directory

# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within

# 发现脚本所在的实际物理路径的目录名：

topdir=$(
cd -P -- "$(dirname -- "$(realpath -e -- "${BASH_SOURCE[0]}")" )" &&
pwd -P
) 

# echo $topdir

# or
# 
# topdir=$(
# cd -P -- "$(dirname -- "$(readlink -e -- "${BASH_SOURCE[0]}")" )" &&
# pwd -P
# )  

# echo $topdir

# cd $topdir/doh-dot-dnscrypt



# 当脚本是一个链接时，下面的操作发现的是该链接所在的目录：
# topdir=$(
# cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
# pwd -P
# )

# echo $topdir

# 进一步的考虑：
# cmake：
# CMakeLIsts.txt
# make：
# Makefile

# 更简单的方法是改变脚本的命名规则，比如：

# cd $topdir/$( echo "${BASH_SOURCE[0]}" | sed -E 's/[.][^.]+$//' )



#  this script is invoked by the following:
# /etc/xdg/autostart/xdg-root-share.desktop


# https://unix.stackexchange.com/questions/348321/purpose-of-the-autostart-scripts-directory

shopt -s nullglob # Ensure shell expansion with 0 files expands to an empty list, rather than trying to read the "*.sh" file

#if [ -z "$XDG_CONFIG_HOME" ]; then
#    XDG_CONFIG_HOME=~/.config
#fi
#for f in "$XDG_CONFIG_HOME/autostart-scripts/"*.sh; do
#    test -x "$f" && . "$f" || true
#done


if command -v inxi > /dev/null 2>&1; then 

# 一些用到的变量：
_user=$( ps -o user= -p $$ | awk '{print $1}' )

# system_uuid
system_uuid=$( sudo dmidecode -s system-uuid )
# root uuid
root_uuid=$( findmnt -alo TARGET,SOURCE,UUID -M /  | tail -1 | awk ' { print $NF } ' )

#getent passwd "$_user" | cut -d: -f6
DEFAULT_HOME=$( awk -v FS=':' -v user=$_user '$1 == user { print $6}' /etc/passwd ) 

# _desktop 的值在某些distro 下，从 .profile 中调用，并不能返回结果。
_distro=$( inxi -c0 -Sxx | grep -Eo 'Distro: [^ ]+' | awk '{ print $2 }' )
_desktop=$( inxi -c0 -Sxx | grep -Eo 'Desktop: [^ ]+' | awk '{ print $2 }' )


# root-share relative vars:
# ROOT_SHARE is exported by /etc/profile.d/root-share.sh

  if [ -n "$ROOT_SHARE"  ]; then
    ROOT_SHARE_HOME=$ROOT_SHARE/home
    ROOT_SHARE_OPT=$ROOT_SHARE/opt
    ROOT_SHARE_INFO=$ROOT_SHARE/"$system_uuid-$root_uuid-$_user"

    DISTRO_DESKTOP=$ROOT_SHARE_HOME/distro-desktop 
      
    if [ -n "$_desktop" ]; then
      echo "Distro: $_distro" | sudo tee $ROOT_SHARE_INFO > /dev/null 2>&1 
      echo "Desktop: $_desktop" | sudo tee -a $ROOT_SHARE_INFO > /dev/null 2>&1 

      if [ ! -d "$ROOT_SHARE_HOME/$_distro-$_desktop" ]; then		  
        sudo mkdir $ROOT_SHARE_HOME/$_distro-$_desktop
        sudo chown -hR $_user:$_user $ROOT_SHARE_HOME/$_distro-$_desktop
      fi
    fi
  fi
fi



# 在 .profile 中运行 inxi 能否检测到 Desktop 的值，
# 是和distro有关的。故不可靠。

# 采用这里的方法是可以的：
# https://unix.stackexchange.com/questions/348321/purpose-of-the-autostart-scripts-directory
#https://specifications.freedesktop.org/autostart-spec/autostart-spec-latest.html



#https://wiki.archlinux.org/index.php/XDG_Base_Directory
#https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

#     XDG_CONFIG_HOME
# 
#         Where user-specific configurations should be written (analogous to /etc).
# 
#         Should default to $HOME/.config.
# 
# 
# 
#     XDG_CACHE_HOME
# 
#         Where user-specific non-essential (cached) data should be written (analogous to /var/cache).
# 
#         Should default to $HOME/.cache.
# 
# 
# 
#     XDG_DATA_HOME
# 
#         Where user-specific data files should be written (analogous to /usr/share).
# 
#         Should default to $HOME/.local/share.







