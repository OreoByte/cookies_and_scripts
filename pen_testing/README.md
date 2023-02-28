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

## Office Macro Template Builder

Simple bash script to quickly format Macro payloads.

![macro_example](https://i.imgur.com/5aifc95.png)

```bash
./build_macro_template.sh
./build_macro_template.sh -h
./build_macro_template.sh -f revshell.p1
./build_macro_template.sh -p "<payload-string>" -o 2
```
