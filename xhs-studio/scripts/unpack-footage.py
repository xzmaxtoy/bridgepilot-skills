#!/usr/bin/env python3
"""Safe unzip for footage zips (Google Drive and iPhone folder downloads).

Why: the system `unzip` can abort on a Chinese file name ("write error (disk full?)") and then
silently skip every file after it, often the biggest clips. This script extracts each file on its
own, keeps going after an error, and CHECKS that every file in the zip listing exists with the
right size. Exit 0 = all files present and complete; exit 1 = something is missing (listed).

Usage: unpack-footage.py FOOTAGE.zip DEST_FOLDER
"""
import os, sys, zipfile

CHUNK = 1024 * 1024


def real_name(info):
    n = info.filename
    if not (info.flag_bits & 0x800):  # no UTF-8 flag: Windows zips often hold GBK names read as cp437
        try:
            n = n.encode("cp437").decode("gbk")
        except (UnicodeEncodeError, UnicodeDecodeError):
            pass
    return n


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    zpath, dest = sys.argv[1], os.path.abspath(sys.argv[2])
    os.makedirs(dest, exist_ok=True)
    z = zipfile.ZipFile(zpath)
    infos = [i for i in z.infolist() if not i.is_dir()]
    skipped_junk = [i for i in infos if "__MACOSX/" in i.filename or os.path.basename(i.filename).startswith("._")]
    infos = [i for i in infos if i not in skipped_junk]
    problems = []
    done = 0
    for info in infos:
        rel = real_name(info).replace("\\", "/")
        target = os.path.abspath(os.path.join(dest, rel))
        if not target.startswith(dest + os.sep):
            problems.append("unsafe path skipped: %s" % rel)
            continue
        try:
            os.makedirs(os.path.dirname(target), exist_ok=True)
            with z.open(info) as src, open(target, "wb") as out:
                while True:
                    b = src.read(CHUNK)
                    if not b:
                        break
                    out.write(b)
            if os.path.getsize(target) != info.file_size:
                problems.append("size mismatch: %s (zip %d, disk %d)" % (rel, info.file_size, os.path.getsize(target)))
            else:
                done += 1
        except Exception as e:  # keep going; report at the end
            problems.append("FAILED %s: %s" % (rel, e))
    print("zip listing: %d files (%d junk entries ignored); extracted OK: %d" % (len(infos), len(skipped_junk), done))
    if problems:
        print("PROBLEMS:")
        for p in problems:
            print(" -", p)
        print("Do NOT use this folder until the list above is empty. Try again, or download the zip again.")
        sys.exit(1)
    print("all files present and complete in", dest)


if __name__ == "__main__":
    main()
