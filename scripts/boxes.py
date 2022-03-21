#!/usr/bin/env python

import multiprocessing
import socket
import sys
from argparse import ArgumentParser, Namespace
from itertools import repeat
from subprocess import check_output
from typing import List

from loguru import logger

from ansible.inventory.manager import InventoryManager
from ansible.parsing.dataloader import DataLoader


def get_all_hosts() -> List[str]:
    data_loader = DataLoader()
    inventory = InventoryManager(loader=data_loader, sources=["inventory.yml"])
    return [str(h) for h in inventory.get_hosts()]


def setup_logging(verbose=False):
    logger.remove()
    logger.add(sys.stdout, level="DEBUG" if verbose else "INFO")


def parse_args() -> Namespace:
    parser = ArgumentParser()
    parser.add_argument("hosts", help="SSH targets", nargs="*")
    parser.add_argument("-s", "--ssh", help="Command to run", default="w")
    parser.add_argument("-v", "--verbose", help="Enable verbosity", action="store_true")

    return parser.parse_args()


def _compose_command(target: str, command: str) -> str:
    if target != str(socket.gethostname()):
        ssh_opts = [
            "-T",  # Disable interactivity
            "-oConnectTimeout=3",  # Timeout after X seconds
            "-oBatchMode=yes",  # Don't ask for passwords
        ]
        command = f"ssh {' '.join(ssh_opts)} {target} {command}"
    return command


def run_command_on_host(target: str, command_on_target: str):
    cmd = _compose_command(target=target, command=command_on_target)
    try:
        logger.debug(f"Running on {target}: {cmd}")
        output = check_output(cmd, shell=True)
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
    setup_logging(args.verbose)
    hosts = args.hosts or get_all_hosts()
    boxes(targets=hosts, command=args.ssh)
