apt install subversion git git-svn

cd /opt/test && rm -rf svn_repository && svnadmin create svn_repository

cd /opt/test && svn checkout file:///opt/test/svn_repository svn_test

cd /opt/test/svn_test && mkdir -p trunk branches/branch1 branches/branch2 Feature/feature1 Feature/feature2

cd /opt/test/svn_test && svn add * --force && svn commit -m "Initial commit: Created directory structure" --username admin

# 为每个分支创建专属文件并以分支名作为用户提交
cd /opt/test/svn_test/branches/branch1 && echo "This is branch1" > branch1.txt && svn add branch1.txt && svn commit -m "Added branch1.txt" --username branch1

cd /opt/test/svn_test/branches/branch2 && echo "This is branch2" > branch2.txt && svn add branch2.txt && svn commit -m "Added branch2.txt" --username branch2

cd /opt/test/svn_test/Feature/feature1 && echo "This is feature1" > feature1.txt && svn add feature1.txt && svn commit -m "Added feature1.txt" --username feature1

cd /opt/test/svn_test/Feature/feature2 && echo "This is feature2" > feature2.txt && svn add feature2.txt && svn commit -m "Added feature2.txt" --username feature2

cd /opt/test/svn_test/trunk && echo "This is trunk" > trunk.txt && svn add trunk.txt && svn commit -m "Added trunk.txt" --username trunk
