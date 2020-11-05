cat > /etc/environment <<EOF
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

yum -y update

yum -y install epel-release
yum -y install htop iperf3 jq net-tools python36 python36-devel screen sysstat tcpdump vim
yum -y install clang clang-analyzer cmake gcc-toolset-9 git graphviz make valgrind
yum -y install bcc-tools bpftrace

python3.6 -m venv /home/vagrant/venv
/home/vagrant/venv/bin/pip install --upgrade pip
/home/vagrant/venv/bin/pip install conan
CONAN_USER_HOME=/home/vagrant /home/vagrant/venv/bin/conan config install http://github.com/ess-dmsc/conan-configuration.git
CONAN_USER_HOME=/home/vagrant scl enable gcc-toolset-9 -- /home/vagrant/venv/bin/conan profile new --detect default
CONAN_USER_HOME=/home/vagrant /home/vagrant/venv/bin/conan profile update settings.compiler.libcxx=libstdc++11 default
chown -R vagrant:vagrant .conan venv

cat >> /home/vagrant/.bashrc <<EOF

# Added by provision.sh
source scl_source enable gcc-toolset-9
alias venv='source /home/vagrant/venv/bin/activate'
EOF

echo ""
echo "Remember to reboot the machine"

