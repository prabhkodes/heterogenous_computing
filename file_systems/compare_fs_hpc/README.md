# Filesystem Benchmarks — ext4 vs XFS vs Btrfs

`fio` benchmarks comparing three Linux filesystems on sequential and random I/O. Run on an AWS EC2 instance with a dedicated EBS volume reformatted for each filesystem.

Raw `fio` output (IOPS, bandwidth, latency percentiles) is in the `.txt` files.

## Reproduce

```bash
# Sequential read — 10 GiB, 1 MiB blocks, queue depth 32
fio --name=TEST --rw=read --bs=1M --size=10G \
    --ioengine=libaio --iodepth=32 --direct=1 \
    --filename=/mnt/<fs>/testfile

# Random write — 4 KiB blocks, 32 parallel jobs
fio --name=TEST --rw=randwrite --bs=4k --size=512M \
    --ioengine=libaio --iodepth=1 --numjobs=32 \
    --direct=1 --filename=/mnt/<fs>/testfile
```
