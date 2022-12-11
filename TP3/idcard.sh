#!/bin/bash
Blue='\033[0;34m'
Color_Off='\033[0m'
index=1
len=$(ss -lnp4H | wc -l)
echo "Machine name : $(hostnamectl | grep hostname | cut -d" " -f4)"
echo "OS $(cat /etc/os-release | grep "NAME=" -m 1| cut -d'"' -f2) and kernel version is $(uname -r)"
echo "IP : $(ip a | grep 'inet ' | tr -s ' '| cut -d '/' -f1 | cut -d ' ' -f3 | tail -n 1)"
echo "RAM : $(free -t -h | grep "Total" | tr -s ' '| cut -d" " -f4) memory available on $(free -t -h | grep "Total" | tr -s ' '| cut -d" " -f2) total memory"
echo "Disque : $(df -h | grep ' /$' |tr -s ' ' | cut -d' ' -f4) space left"
echo "Top 5 processes by RAM usage :"
for i in $(seq 1 5)
do
echo "  - $(ps -e -o cmd= --sort=-%mem | head -n ${i} | tail -n+${i}  | cut -d" " -f1)"
done
echo "Listening ports :"
while [[ ${index} -le ${len} ]]
do
echo "  - $(ss -ln4Hp | tr -s ' '| cut -d' ' -f5 | cut -d':' -f2 | head -n ${index} | tail -n +${index}) $(ss -ln4Hp | tr -s ' '| cut -d' ' -f1 | head -n ${index} | tail -n +${index}) : $(ss -ltun4Hp | tr -s ' ' | cut -d'"' -f2 | head -n ${index} | tail -n +${index})"
index=$(( index + 1 ))
done
echo " "
curl https://cataas.com/cat --output cat 2> /dev/null
cat_name='cat'
cat_type="$(file cat | cut -d' ' -f2)"
if [[ "${cat_type}" == JPEG ]]
then
file_type='.jpeg'
elif [[ "${cat_type}" == PNG ]]
then
file_type='.png'
elif [[ "${cat_type}" == GIF ]]
then
file_type='.gif'
else
echo "Not good format"
fi
new_cat_file="cat${file_type}"
cp "${cat_name}" "${new_cat_file}"
rm "${cat_name}"
echo "Here is your random cat : ${new_cat_file}"
