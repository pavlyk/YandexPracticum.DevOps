# TASK 3.1

## 1. 
`ssh student@51.250.67.183`  
`sudo adduser jarservice`  
`sudo addgroup jarusers`  
`sudo adduser front-user`  
`sudo usermod -a -G jarusers jarservice`
`java -jar /var/jarservice/sausage-store-0.0.1-SNAPSHOT.jar`


## 2. 
`screen -S front`  
`sudo cd /var/www-data && sudo http-server ./dist/frontend/ -p 80 --proxy http://localhost:8080`  


## 3. 
`sudo vi /etc/systemd/system/sausage-store-backend.service`  
```shell
[Unit]
Description=Sausage store backend daemon
After=syslog.target

[Service]
WorkingDirectory=/var/jarservice/
ExecStart=/usr/bin/java -jar sausage-store-0.0.1-SNAPSHOT.jar --server.port=8888
Restart=on-failure
User=root
Type=simple
RestartSec=5s
StartLimitBurst=5
Environment="REPORT_PATH=/var/www-data/htdocs"
Environment="LOG_PATH=/var/jarservice/"

[Install]
WantedBy=multi-user.target
```

`sudo systemctl daemon-reload`  
`sudo systemctl restart sausage-store-backend.service`  
`sudo systemctl status sausage-store-backend.service`  


## 4.
### 4.1. Убедитесь, что всё свободное место закончилось
`df -hT`  
`du -schx`  


### 4.2. Создайте на своей виртуальной машине 2 диска, по 1 ГБ каждый.
`sudo fdisk /dev/vdb`  
```shell
g
Created a new GPT disklabel (GUID: 5329DF0D-93BE-7E4C-BF77-AC6932585062).

Command (m for help): n
Partition number (1-128, default 1):
First sector (2048-8388574, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-8388574, default 8388574): +1G
Created a new partition 1 of type 'Linux filesystem' and of size 1 GiB.

Command (m for help): n
Partition number (2-128, default 2):
First sector (2099200-8388574, default 2099200):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2099200-8388574, default 8388574): +1G
Created a new partition 2 of type 'Linux filesystem' and of size 1 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

`sudo partprobe`  # перезагрузить таблицу разделов утилитой partprobe

### 4.3. Создайте виртуальную группу под названием log_vg и включите туда PV для обоих созданных дисков
`sudo pvcreate /dev/vdb1 /dev/vdb2`  
```shell
  Physical volume "/dev/vdb1" successfully created.
  Physical volume "/dev/vdb2" successfully created.
```    

`sudo pvs`  
```shell
  PV         VG Fmt  Attr PSize PFree
  /dev/vdb1     lvm2 ---  1.00g 1.00g
  /dev/vdb2     lvm2 ---  1.00g 1.00g
```
 
`sudo pvdisplay`  
```shell
  "/dev/vdb1" is a new physical volume of "1.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/vdb1
  VG Name
  PV Size               1.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               cCFndR-2ApX-mXx1-K5Mz-Hf2q-fNYM-2Q35PI

  "/dev/vdb2" is a new physical volume of "1.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/vdb2
  VG Name
  PV Size               1.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               fkeZjT-ciiF-U5Wm-0bwG-l8xb-E1KP-kUsgqM
```

#### и только теперь создадим виртуальную группу разделов lvm (VG)
`sudo vgcreate log_vg /dev/vdb1 /dev/vdb2`  
```shell
  Volume group "log_vg" successfully created
```

`sudo vgs`  
```shell
  VG     #PV #LV #SN Attr   VSize VFree
  log_vg   2   0   0 wz--n- 1.99g 1.99g
```

`sudo vgdisplay`  
```shell
  --- Volume group ---
  VG Name               log_vg
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               1.99 GiB
  PE Size               4.00 MiB
  Total PE              510
  Alloc PE / Size       0 / 0
  Free  PE / Size       510 / 1.99 GiB
  VG UUID               vbr2bA-vm1v-GFvK-GaP4-F1KZ-gGPS-MsWhWM
```

### 4.4. Создайте виртуальный раздел lvm log_vol на 100% группы log_vg
`sudo lvcreate -l +100%FREE -n log_vol log_vg`  
```shell
  Logical volume "log_vol" created.
```

`sudo lvs`
```shell
  LV      VG     Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  log_vol log_vg -wi-a----- 1.99g
```  

`sudo lvdisplay`  
```shell
  --- Logical volume ---
  LV Path                /dev/log_vg/log_vol
  LV Name                log_vol
  VG Name                log_vg
  LV UUID                fpVwn8-kcx8-nZAi-LVm0-EnaN-Yg5e-Sln0SY
  LV Write Access        read/write
  LV Creation host, time fhmfcr5pto87rkevkqmj, 2022-06-21 08:23:09 +0000
  LV Status              available
  # open                 0
  LV Size                1.99 GiB
  Current LE             510
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0
```

### 4.5. Создайте файловую систему ext4 на log_vol и примонтируйте её в раздел /logs
`sudo mkfs.ext4 /dev/log_vg/log_vol`  
```shell
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 522240 4k blocks and 130560 inodes
Filesystem UUID: bdee933e-56fa-4f82-9884-171f4c11c9a5
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

`sudo mkdir /logs`  
`sudo mount /dev/log_vg/log_vol /logs`  

### 4.6. Пропишите монтирование в /etc/fstab, чтобы не потерялось при перезапуске виртуалки
`/dev/log_vg/log_vol /logs               ext4    defaults 1 2 `  


## 5.
#### Добавьте оставшееся место на диске в log_vol. Расширьте файловую систему, запустите df -h и убедитесь, что она действительно расширилась
`sudo fdisk /dev/vdb`  
```shell
Command (m for help): n
Partition number (3-128, default 3):
First sector (4196352-8388574, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-8388574, default 8388574):
Created a new partition 3 of type 'Linux filesystem' and of size 2 GiB.

Command (m for help): w
The partition table has been altered.
Syncing disks.
```

`sudo pvcreate /dev/vdb3`  
```shell
  Physical volume "/dev/vdb3" successfully created.
```

`sudo vgextend log_vg /dev/vdb3`  
```shell
  Volume group "log_vg" successfully extended
```

`sudo vgs`  
```shell
  VG     #PV #LV #SN Attr   VSize  VFree
  log_vg   3   1   0 wz--n- <3.99g <2.00g
```  

`sudo lvextend -l +100%FREE log_vg/log_vol`  
```shell
  Size of logical volume log_vg/log_vol changed from 1.99 GiB (510 extents) to <3.99 GiB (1021 extents).
  Logical volume log_vg/log_vol successfully resized.
```

`sudo resize2fs /dev/log_vg/log_vol`  
```shell
resize2fs 1.45.5 (07-Jan-2020)
Filesystem at /dev/log_vg/log_vol is mounted on /logs; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/log_vg/log_vol is now 1045504 (4k) blocks long.
```

`sudo df -h`  
```shell
Filesystem                  Size  Used Avail Use% Mounted on
udev                        1.9G     0  1.9G   0% /dev
tmpfs                       394M  900K  393M   1% /run
/dev/vda2                    50G   40G  7.3G  85% /
tmpfs                       2.0G     0  2.0G   0% /dev/shm
tmpfs                       5.0M     0  5.0M   0% /run/lock
/dev/mapper/log_vg-log_vol  3.9G  8.0M  3.7G   1% /logs
/dev/vdc1                   2.0G  2.0G   20K 100% /var/jarservice
tmpfs                       394M     0  394M   0% /run/user/112
tmpfs                       394M     0  394M   0% /run/user/1001
```


## 6.
```shell
[Unit]
Description=Sausage store backend daemon
After=syslog.target

[Service]
WorkingDirectory=/var/jarservice/
ExecStart=/usr/bin/java -jar sausage-store-0.0.1-SNAPSHOT.jar --server.port=8888
Restart=on-failure
User=root
Type=simple
RestartSec=5s
StartLimitBurst=5
Environment="REPORT_PATH=/var/www-data/htdocs"
Environment="LOG_PATH=/logs/"
StandardOutput=append:/logs/out.log

[Install]
WantedBy=multi-user.target
```
