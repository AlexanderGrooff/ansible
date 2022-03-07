#!/usr/bin/env python

from argparse import ArgumentParser, Namespace
import multiprocessing
from itertools import repeat
from loguru import logger
from subprocess import check_output
from typing import List
from ansible.parsing.dataloader import DataLoader
from ansible.inventory.manager import InventoryManager


def get_all_hosts() -> List[str]:
    data_loader = DataLoader()
    inventory = InventoryManager(loader = data_loader, sources=["inventory.yml"])
    return inventory.get_hosts()


def parse_args() -> Namespace:
    parser = ArgumentParser()
    parser.add_argument("hosts", help="SSH targets", nargs="*")
    parser.add_argument("-s", "--ssh", help="Command to run", default="w")

    return parser.parse_args()


def run_command_on_host(target: str, command: str):
    ssh_opts = [
        "-T",                   # Disable interactivity
        "-oConnectTimeout=3",   # Timeout after X seconds
        "-oBatchMode=yes",      # Don't ask for passwords
    ]
    ssh_cmd = f"ssh {' '.join(ssh_opts)} {target} {command}"
    try:
        logger.debug(f"Running on {target}: {command}")
        output = check_output(ssh_cmd, shell=True)
        print(f"{target}: {output.decode('utf-8')}")
    except KeyboardInterrupt:
        return
    except Exception as e:
        logger.warning(f"Failed running command on {target}: {e}")


def boxes(targets: List[str], command: str):
    with multiprocessing.Pool(5) as pool:
        pool.starmap(run_command_on_host, zip(targets, repeat(command)))


if __name__ == "__main__":
    args = parse_args()
    hosts = args.hosts or get_all_hosts()
    boxes(targets=hosts, command=args.ssh)
