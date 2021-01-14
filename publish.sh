# 生成最新的文件
source ~/.nvm/nvm.sh
nvm use v10.23.0
gitbook build
# 删除原来doc下的文件
rm -r docs/

# 复制文件
cp -r _book/ docs

# 提交
git add .

if [ -z "$1" ];
then 
    git commit -m "$1"
else 
    git commit -m "update"
fi


