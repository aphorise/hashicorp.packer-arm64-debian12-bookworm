#!/bin/bash
export DEBIAN_FRONTEND=noninteractive ;
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

# Repair "==> default: stdin: is not a tty" message
sudo ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf ;
sudo dpkg-reconfigure debconf -f noninteractive -p critical ;

export LANGUAGE=en_US.UTF-8 ;
printf "LC_ALL=${LANGUAGE}\n" >> /etc/environment
# printf "en_US.UTF-8 UTF-8\n" >> /etc/locale.gen  # // any other custom local or defaults if needed.
locale-gen ${LANGUAGE} > /dev/null 2>&1 && dpkg-reconfigure locales > /dev/null 2>&1 ;
printf "OS LOCALS / LANG: '${LANGUAGE}' set.\n" ;
#export LC_ALL=${LANGUAGE} ;

# // persist journal entries between reboots:
mkdir -p /var/log/journal && chown root:adm /var/log/journal ;
#sed -i 's/^#Storage=auto/Storage=auto/g' /etc/systemd/journald.conf ;

UNAME="$(uname -ar)" ;
# // OS Version specific apps missing:
# PKG_UBUNTU='realpath' ; # if [[ ${UNAME} == *"Ubuntu"* ]] ; then sudo apt-get update > /dev/null && sudo apt-get install -yq ${PKG_UBUNTU} > /dev/null ; fi ;
# // common utils & build tools: make, cpp, etc.
PKGS="locales locales-all nfs-common rsync git hdparm policykit-1 unzip curl htop screen tmux jq" ;
PKGS="${PKGS} wget build-essential libssh-dev bc mtr glances fio sysstat vim ed" ;
PKGS="${PKGS} linux-perf net-tools ack tcpdump nmap iperf iperf3 ipcalc" ;
PKGS="${PKGS} pydf cmatrix bmon socat btop iotop iftop atop mc git lshw" ;  # inxi pydf cmatrix bmon
PKGS="${PKGS} nmon iptraf nload opensc softhsm2 tree asciinema" ;
PKGS="${PKGS} lolcat fzf duf nethogs vnstat rcconf" ;
PKGS="${PKGS}" ;  # ${PKG_UBUNTU} any-other-packages" ;
printf "OS INSTALLING: ${PKGS:0:69}...\n" ;
sudo apt-get update > /dev/null && apt-get install -yq ${PKGS} > /dev/null ;

# // disable default login
sudo sh -c 'echo "" > /etc/motd'

# // install manager & mproc
#bash -c "$(wget -qO - 'https://shlink.makedeb.org/install')" 2>&1>/dev/null
#git clone 'https://mpr.makedeb.org/mprocs' 2&1>/dev/null && cd mprocs && makedeb -si --no-confirm 2>&1>/dev/null

# // NOT AVAILABLE ON ARM64 (not without building).
#BANDWHICH_VERSION=$(curl -qs "https://api.github.com/repos/imsnif/bandwhich/releases/latest" | grep -Po '"tag_name": ".*' | cut -d'"' -f 4 | cut -d'v' -f2)
#curl -sqLo bandwhich.tar.gz "https://github.com/imsnif/bandwhich/releases/latest/download/bandwhich-v${BANDWHICH_VERSION}-x86_64-unknown-linux-musl.tar.gz"
#sudo tar xf bandwhich.tar.gz -C /usr/local/bin 2>&1 > /dev/null
#rm -rf bandwhich.tar.gz

# // .bashrc profile alias and history settings.
sBASH_DEFAULT='''
SHELL_SESSION_HISTORY=0
export HISTSIZE=1000000
export HISTFILESIZE=100000000
export HISTCONTROL=ignoreboth:erasedups
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
alias ack="ack -i --color-match=\\\"bold white on_red\\\""
alias nano="nano -c"
alias grep="grep --color=auto"
alias ls="ls --color=auto"
alias dir="dir --color=auto"
alias reset="reset; stty sane; tput rs1; clear; echo -e \\"\033c\\""
alias jv="sudo journalctl -u vault.service --no-pager -f --output cat"
alias jreset="sudo journalctl --rotate && sudo journalctl --vacuum-time=1s"

function jwt-decode() {
	sed "s/\./\\n/g" <<< $(cut -d. -f1,2 <<< $1) | base64 --decode | jq
}

function jwtd() {
	if [[ -x $(command -v jq) ]]; then
		jq -R "split(\\".\\") | .[0],.[1] | @base64d | fromjson" <<< "${1}"
	fi
}

PS1="${debian_chroot:+($debian_chroot)}\[\033[38;5;244m\]\\u@\[\033[38;5;202m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
''' ;
printf "${sBASH_DEFAULT}" >> ~/.bashrc ;
if [[ $(logname) != $(whoami) ]] ; then printf "${sBASH_DEFAULT}" >> /home/$(logname)/.bashrc ; fi ;
printf 'BASH: defaults in (.bashrc) profile set.\n' ;

## // package source mirrors to allow for obtaining os & version specific software:
## // default main or stable apps
#sudo cp /etc/apt/sources.list /etc/apt/sources.list.d/unstable.list
#if [[ ${UNAME} == *"Debian"* ]] ; then
#	printf 'APT::Default-Release "stable";\n' > /etc/apt/apt.conf.d/99defaultrelease ;
#	PKG_TRG='unstable' ;
#	PKG_SRC="$(grep -E '#|deb-src|security|^$' -v /etc/apt/sources.list.d/unstable.list)" ;
#	PKG_SRC=${PKG_SRC/debian[[:space:]]*/'debian unstable main'} ;
#elif [[ ${UNAME} == *"Ubuntu"* ]] ; then
#	PKG_TRG='groovy' ;
#	set +e ;  # // disbale errors
#	PKG_SRC="$(grep -E '#|deb-src|security|^$' -v /etc/apt/sources.list.d/unstable.list | grep 'bionic universe')" ;
#	set -e ;  # // re-enable errors
#	if ! [[ ${PKG_SRC} == "" ]] ; then
#		PKG_SRC=${PKG_SRC/'ubuntu bionic'/'ubuntu groovy main '} ;
#	else
#		PKG_SRC="$(grep -E '#|deb-src|security|^$' -v /etc/apt/sources.list.d/unstable.list | grep -E 'ubuntu\ \w+\ universe')" ;
#		PKG_SRC=${PKG_SRC/'ubuntu focal'/'ubuntu groovy main '} ;
#	fi ;
#else
#	printf "\e[31mERROR: Linux OS / Distribution not recognited - only Debian or Ubuntu are currently supported.\e[0m" ; exit 1 ;
#fi ;
#printf "# // UNSTABLE sources (for latest apps 2.6+):\n${PKG_SRC}\n" > /etc/apt/sources.list.d/unstable.list ;
#apt-get update > /dev/null 2>&1 ;

# // disable swap
swapoff /dev/dm-1 ;

# // DO A BIT OF COMPACTION
set +e ;
sudo dd if=/dev/zero of=/EMPTY bs=1M
set -e ;
sudo rm -rf /EMPTY
