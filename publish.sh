# 生成最新的文件
source ~/.nvm/nvm.sh
nvm use v10.23.0
gitbook build
# 删除原来doc下的文件
rm -r doc/

# 复制文件
cp -r _book/ doc

