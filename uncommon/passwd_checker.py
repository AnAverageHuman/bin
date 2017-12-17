#!/usr/bin/env python3

# Try running it like this from bash:
# ./passwd.py -j200 -pbo "$(date +%s_%c)" 123.456.789.{1..255} 2>/dev/null

# BUGS/TODO:
# - specifying -p without -o causes stdout display issues due to line length
# - should check for shells not /bin/false or /sbin/nologin
# - implement two pools, one for network requests and another for processing?
# - sort output by IP or username; or output in CSV-compatible format

from argparse import ArgumentParser
from multiprocessing import cpu_count, RLock
from multiprocessing.dummy import Pool
from os import getpid, kill
from re import compile
from signal import SIGKILL
from subprocess import check_output, CalledProcessError
from sys import stdout
from time import sleep, time

PASSWD_FILE = "/etc/passwd"
PASSWD_DELIM = ":"

# Varies depending on what services are installed by default.
GOOD_USERS = [
    "_apt",
    "avahi",
    "avahi-autoipd",
    "backup",
    "bin",
    "colord",
    "daemon",
    "dnsmasq",
    "games",
    "gnats",
    "hplip",
    "irc",
    "kernoops",
    "lightdm",
    "list",
    "lp",
    "mail",
    "man",
    "messagebus",
    "mongodb",
    "news",
    "nobody",
    "postfix",
    "proxy",
    "pulse",
    "root",
    "rtkit",
    "saned",
    "service",
    "speech-dispatcher",
    "sshd",
    "statd",
    "sync",
    "sys",
    "syslog",
    "systemd-bus-proxy",
    "systemd-network",
    "systemd-resolve",
    "systemd-timesync",
    "usbmux",
    "uucp",
    "uuidd",
    "whoopsie",
    "www-data"
]

# This might potentially discard possible suspects!
GOOD_REGEXES = [
    r"guest-.{6}"
]

complete = 0
cLock = RLock()
outfile = stdout
start_time = time()


def exit_hook():
    print("Finished {} items in {:.3f}s".format(complete, time() - start_time))
    outfile.close()


def compile_regexes(glob_list):
    for i in range(0, len(glob_list)):
        glob_list[i] = compile(glob_list[i])


def add_complete(num=1):
    global complete
    with cLock:
        complete += num


def get_bad_users(file_contents):
    ret = []
    for line in file_contents.splitlines():
        username = line.split(PASSWD_DELIM, 1)[0]
        if username not in GOOD_USERS and \
           not all(r.match(username) for r in GOOD_REGEXES):
            ret.append(username)
    return ret


def main(ip):
    passwd_contents = ""

    try:
        passwd_contents = check_output(
            cmd_head + [ip, "cat", PASSWD_FILE]).decode()
    except CalledProcessError:
        add_complete()
        return

    for bu in get_bad_users(passwd_contents):
        print("[{}] {}".format(ip, bu), file=outfile)
    add_complete()


if __name__ == '__main__':
    p = ArgumentParser(description="Find unexpected users on remote machines.")
    p.add_argument('--batch', '-b', action='store_true',
                   help="prevent prompting for password")
    p.add_argument('--identity', '-i', action='store', metavar="identity_file",
                   help="specify identity file")
    p.add_argument('--jobs', '-j', action='store', metavar="jobs",
                   default=cpu_count(), help="number of parallel jobs")
    p.add_argument('--login', '-l', action='store', metavar='login_name',
                   help="pass login name to OpenSSH client")
    p.add_argument('--outfile', '-o', action='store', metavar="output_file",
                   help="specify output file")
    p.add_argument('--progress', '-p', action='store_true',
                   help="indicate progress")
    p.add_argument('ip', nargs='+', action='append',
                   help="IP of machine to test")

    args = p.parse_args()
    numitems = len(args.ip[0])

    cmd_head = ["ssh"]
    if args.batch:
        cmd_head += ["-oBatchMode=yes"]

    if args.login:
        cmd_head += ["-l", args.login]

    if args.identity:
        cmd_head += ["-i", args.identity]

    if args.outfile:
        outfile = open(args.outfile, "w")

    compile_regexes(GOOD_REGEXES)

    with Pool(int(args.jobs)) as p:
        p.map_async(main, args.ip[0])

        try:
            while complete < numitems:
                if args.progress:
                    print("Done {} of {} in {:.3f}s".format(
                        complete, numitems, time() - start_time), end="\r")
                sleep(1)
            p.close()
            exit_hook()
        except KeyboardInterrupt:
            p.terminate()
            exit_hook()
            kill(getpid(), SIGKILL)
