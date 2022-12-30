# Scripts to help the `Pen-Test` process
## Download file request builder

Simple bash script to quickly format different ways to download a file.

![linux_example](https://i.imgur.com/n7XZ33p.png)

```bash
./download_builder.sh -h
./download_builder.sh
./download_builder.sh -f sploit.exe -lh 10.10.14.51 -o linux
./download_builder.sh -f sploit.exe -lh tun0 -o win -f uwu.exe -lp 80 -s corp_share
```
