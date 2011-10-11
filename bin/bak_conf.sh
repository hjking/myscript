#!/bin/bash

# 1. backup my config file
#     - vimrc
#     - screenrc
#     - emacs
#     - bashrc/bash_login/bash_profile
#     - cshrc/tcshrc
#     - cvsrc
#     - mrxvtrc
#     - Xdefaults
#     - zshrc
# 2. backup my scripts
#     - vcs running script
#     - verdi running script
#     - msim running script
#     - DC running script
#     - spyglass running script
#     - scripts in ~/bin dir

BAK_DIR=~/my_bak
BIN_DIR=${BAK_DIR}/bin
EDA_DIR=${BAK_DIR}/eda

echo "Creating backup dir..."
mkdir ${BAK_DIR}
mkdir -p ${BIN_DIR}
mkdir -p ${EDA_DIR}

cd ~

echo "Backup Important Files..."

echo "1. backup bash config files..."
cp ~/.bash_login   ${BAK_DIR}/bash_login
cp ~/.bash_profile ${BAK_DIR}/bash_profile
cp ~/.bashrc ${BAK_DIR}/bashrc
echo ">>> Done!"

echo "2. backup csh/tcsh config files..."
cp ~/.cshrc ${BAK_DIR}/cshrc
cp ~/.login ${BAK_DIR}/login
cp ~/.logout ${BAK_DIR}/logout
cp ~/.tcshrc ${BAK_DIR}/tcshrc
echo ">>> Done!"

echo "3. backup cvs config files..."
cp ~/.cvsrc ${BAK_DIR}/cvsrc
echo ">>> Done!"

echo "4. backup emacs config files..."
cp ~/.emacs ${BAK_DIR}/emacs
cp ~/.emacs.d ${BAK_DIR}
echo ">>> Done!"

echo "5. backup vim config files..."
cp ~/.vimrc ${BAK_DIR}/vimrc
echo ">>> Done!"

echo "6. backup screen config files..."
cp ~/.screenrc ${BAK_DIR}/screenrc
echo ">>> Done!"

echo "7. backup zsh config files..."
cp ~/.zshrc ${BAK_DIR}/zshrc
echo ">>> Done!"

echo "8. backup terminal config files..."
cp ~/.mrxvtrc ${BAK_DIR}/mrxvtrc
cp ~/.Xdefaults ${BAK_DIR}/Xdefaults
echo ">>> Done!"

echo "9. backup my script files..."
cd ~
find bin -type f -maxdepth 1 | tar czvf bin.tgz --exclude=bin.tgz -T -
mv bin.tgz ${BIN_DIR}

echo ">>> Done!"

echo "10. backup my eda tool script files..."
cd ~/sim_script
tar czf dc.tar.gz dc; mv dc.tar.gz ${EDA_DIR}
tar czf spyglass.tar.gz spyglass; mv spyglass.tar.gz ${EDA_DIR}
tar czf vcs.tar.gz vcs; mv vcs.tar.gz ${EDA_DIR}
tar czf verdi.tar.gz verdi; mv verdi.tar.gz ${EDA_DIR}
tar czf vsim.tar.gz vsim; mv vsim.tar.gz ${EDA_DIR}
echo ">>> Done!"

echo "Backup Completed..."
