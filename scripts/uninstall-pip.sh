# pip3 import error: cannot import name 'main'
# To solve above error, the below command should be performed

python -m pip uninstall pip
yum remove python2*-pip
yum remove python3*-pip
whereis pip

wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
python3 /tmp/get-pip.py
# pip install --user pipenv
# pip3 install --user pipenv
# echo "PATH=$HOME/.local/bin:$PATH" >> ~/.profile
# source ~/.profile
# whereis pip
