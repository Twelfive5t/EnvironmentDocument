git clone https://git.fscut.com/rtos/tools/svn2git.git svn_test3
cd svn_test3

# git仓库配置svn相关
git config svn-remote.svn.url "file:///opt/test/svn_repository"
git config --add svn-remote.svn.fetch trunk:refs/remotes/origin/main
git config svn.authorsfile authors.txt
cp ../svn_test2/authors.txt ./

# 通过git svn获取svn仓库的提交
git svn fetch
git svn rebase
git log

# 通过git提交代码到svn仓库
echo "This is trunk 2(by git)" > trunk.txt
git add trunk.txt
git commit -m "trunk.txt 2(by git)"
# 下面两台命令不分先后
# git svn dcommit会将git提交的代码提交到svn仓库
# git push会将代码提交到远程git仓库
git svn dcommit
git push -u origin main
