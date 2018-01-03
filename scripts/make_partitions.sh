#!/bin/bash
# Automatically create 3 partitions, manually create final partition
# Part 1: MBR Boot partition for grub bios boot
# Part 2: Partition for base OS (Setup raid on sda/sdb)
# Part 3: 1G OSD Journal
# Part 4: Variable size OSD with remainer
# The curtin preseed will set GPT labels on partition 1,3,4

MACHINE=$1
# # Clear the partitions
for partid in $(maas maas-root partitions read $MACHINE sda |jq '.[] | .id'); do
  maas maas-root partition delete $MACHINE nvme0n1 $partid
done

for partid in $(maas maas-root partitions read $MACHINE sdb |jq '.[] | .id'); do
  maas maas-root partition delete $MACHINE nvme0n1 $partid
done

# maas admin partition delete $MACHINE sda sda-part4
# maas admin partition delete $MACHINE sda sda-part3
# maas admin partition delete $MACHINE sda sda-part2
# maas admin partition delete $MACHINE sda sda-part1
# maas admin partition delete $MACHINE sdb sdb-part4
# maas admin partition delete $MACHINE sdb sdb-part3
# maas admin partition delete $MACHINE sdb sdb-part2
# maas admin partition delete $MACHINE sdb sdb-part1

# Setup sda
maas admin block-device set-boot-disk $MACHINE sdb
maas admin partitions create $MACHINE sda size=5M
maas admin partitions create $MACHINE sda size=100G
maas admin partitions create $MACHINE sda size=100M
# maas admin partitions create $MACHINE sda size=XXX-Manual
maas admin block-device update $MACHINE sda partition_table_type=gpt

# Setup sdb
maas admin block-device set-boot-disk $MACHINE sda
maas admin partitions create $MACHINE sdb size=5M
maas admin partitions create $MACHINE sdb size=100G
maas admin partitions create $MACHINE sdb size=100M
# maas admin partitions create $MACHINE sdb size=XXX-Manual
maas admin block-device update $MACHINE sdb partition_table_type=gpt