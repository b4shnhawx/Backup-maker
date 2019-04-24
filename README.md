# BM: Backup-maker
### Description
An upgraded version of [OS-Backup-for-Raspberry](https://github.com/davidahid/OS-Backup-for-Raspberry). Now compatible with all Linux systems. This script can avoid the unintentional erase of data using colors to warn the user where he wants to save the backup and minimalize the typical human errors or neglects in the making a backup.

This script can't avoid completly the human errors, its just to minimalize that errors!!

### Installation
To install the script just type the following instructions.
```sh
cd ~
git clone https://github.com/davidahid/Backup-maker
cd Backup-maker/scripts/
bash installer.sh
```

Optionally we can remove the downloaded git.
```sh
cd
rm -rf Backup-maker
```

Now we can execute the backup maker script in the terminal as a conventional command!
```sh
bckpm
```

The BCKPM script its been saved in `/etc/backup_maker.sh` and the binary file in `/bin/bckpm`.
### Example
