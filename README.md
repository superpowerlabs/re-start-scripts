# re-start-scripts

To install it in a React repo in the folder bin
```
if [[ -d "bin" ]]; then cp -r bin bin-backup; fi
git clone https://github.com/superpowerlabs/re-start-scripts bin
rm -rf bin/.git
mv bin-backup/* bin
rm -rf bin-backup
```
