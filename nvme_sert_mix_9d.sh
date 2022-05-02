#!/bin/bash
rm -rf SERT_jobfile_*
rm -rf disk.text
#nvme -list | grep "/dev/" | awk '{print$1}' >> disk.text
echo $2 >> disk.text
i=1
time=$1
while read line
do
echo -e "[global]\nlockmem=1258291\nbs=128k\nblockalign=128k\nioengine=libaio\niodepth=128\ndirect=1\ninvalidate=1\ntime_based\nnorandommap\nrandrepeat=0\nruntime=${time}\ngroup_reporting=1\nrw=rw\nrwmixread=50\nrwmixwrite=50\n[NVME_SERT_mix_r/w:50%:50%]\nfilename=$line\noffset=0G\nsize=1G" >> SERT_jobfile_${i}
i=$(($i+1))
done < disk.text

echo "Start SSD stress"

nonvme=`nvme -list | grep "/dev/" | awk '{print$1}' | wc -l `
echo "Number of disks are: $nonvme"
for i in  `seq 1 ${nonvme}`
do
fio SERT_jobfile_${i} --output=SERT_disk_${i}.log
done
### fio --output=SERT_disk_${i}.log SERT_jobfile_${i} &>/dev/null &
