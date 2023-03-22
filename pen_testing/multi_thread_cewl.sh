#!/bin/bash
chelp(){
pygmentize -l csh <<eof
-------------------------------------------
{/!\} Multi Threaded Cewl Tool {/!\}
-------------------------------------------
# options
-u // (URL of target host)
-f // (List of URLs in a File instead of a single url)
-w // (Output Write File, Default: url_words.txt)
-d // (Cewl's page depth option)
-t // (Threads by number of CPU cores you want to use, Default: 2)
-o // (Output directory name of all the URLS, Default: all_urls_dump_dir)
-h // (Return Help Menu)

# examples
./multi_thread_cewl.sh -u oreobyte.com -w oreo.words
./multi_thread_cewl.sh -f urlfile.txt -o everything -t 4 -w final_sorted.txt
eof
exit 0
}
cewl_list(){
if [ -z "$file" ]; then
	echo "$cyan[*]$reset Cewl a single URL option in use"
	cewl -e -d $depth -w $write_file $url | xargs -P $cpu -n 1
	echo "$green[+]$reset Single URL option with cewl has finished"
else
	if [ -d $output_dir ]; then
		echo "$green[+]$reset $output_dir has already been created"
	else
		echo "$cyan[*]$reset A new directory named $output_dir is being created"
		mkdir $output_dir
	fi
	echo "$cyan[*]$reset Starting cewl command by URLs file"
	while IFS= read -r f_urls; do
		# Need to figure out a better way to do this the xargs makes it go faster but misses so many words...
		#cewl -e -d $depth -w ./$output_dir/$f_urls.txt $f_urls | xargs -P $cpu -n 1
		cewl -e -d $depth -w ./$output_dir/$f_urls.txt $f_urls
	done < $file
	echo "$green[+]$reset Finsihed cewl command from URLs file, concat all results into one file $write_file"
	cat ./$output_dir/*.txt > ./$output_dir/all_furone.txt
	cat ./$output_dir/all_furone.txt |sort -u > $write_file
fi
}
if [ -z "$1" ]; then
	chelp
fi
cpu=2
write_file="url_words.txt"
output_dir="all_urls_dump_dir"
#red=$(tput setaf 1)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
reset=$(tput sgr0)
while [[ "$#" -gt 0 ]]
do
case "$1" in
	-u) url=$2;;
	-f) file=$2;;
	-t) threads=$2;;
	-w) write_file=$2;;
	-d) depth=$2;;
	-o) output_dir=$2;;
	-h) chelp
esac
shift
done
if [[ $url != '' ]] || [[ $file != '' ]];then
	cewl_list
else
	chelp
fi
