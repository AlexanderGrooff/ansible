import tarfile
from tempfile import TemporaryFile

import pendulum
import requests
from airflow.decorators import dag, task
from kubernetes import client, config
from kubernetes.stream.stream import stream


@dag(
    schedule_interval=None,
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    tags=["freqtrade"],
)
def update_freqtrade_strategy_etl():
    @task
    def get_latest_release():
        """
        Get the latest release from Github
        """
        # curl -sSL https://api.github.com/repos/iterativv/NostalgiaForInfinity/releases/latest  \
        #     | jq -r .tarball_url  \
        #     | wget -qO $STRAT_DOWNLOAD_TARBALL -i -
        # tar xzf $STRAT_DOWNLOAD_TARBALL -C $STRAT_UNARCHIVE_DIR
        url = "https://api.github.com/repos/iterativv/NostalgiaForInfinity/releases/latest"
        print(f"Fetching latest release from url {url}")
        resp = requests.get(url, allow_redirects=True)
        resp.raise_for_status()
        tarball_url = resp.json()["tarball_url"]

        return tarball_url

    @task
    def get_first_pod() -> str:
        """
        Get the first pod in the freqtrade namespace
        """
        config.load_incluster_config()
        v1 = client.CoreV1Api()

        # List namespaces
        # namespaces = v1.list_namespace()
        # print(f"Namespaces: {namespaces}")

        pods = v1.list_namespaced_pod("freqtrade")
        pod = pods.items[0].metadata.name
        return pod

    def copy_file_to_pod(pod_name, namespace, src_path, dest_path):
        config.load_incluster_config()
        api = client.CoreV1Api()
        # Copying file
        print(f"Copying {src_path} to {pod_name}/{namespace}:{dest_path}")

        exec_command = ["tar", "cf", "-", src_path]

        with TemporaryFile() as tar_buffer:
            resp = stream(
                api.connect_get_namespaced_pod_exec,
                pod_name,
                namespace,
                command=exec_command,
                stderr=True,
                stdin=True,
                stdout=True,
                tty=False,
                _preload_content=False,
            )

            while resp.is_open():
                resp.update(timeout=1)
                if resp.peek_stdout():
                    out = resp.read_stdout()
                    # print("STDOUT: %s" % len(out))
                    tar_buffer.write(out.encode("utf-8"))
                if resp.peek_stderr():
                    print("STDERR: %s" % resp.read_stderr())
            resp.close()

            tar_buffer.flush()
            tar_buffer.seek(0)

            with tarfile.open(fileobj=tar_buffer, mode="r:") as tar:
                for member in tar.getmembers():
                    if member.isdir():
                        continue
                    fname = member.name.rsplit("/", 1)[1]
                    tar.makefile(member, dest_path + "/" + fname)

    @task
    def download_strategy(tarball_url: str, pod: str):
        """
        Download tarball, extract and upload to pod
        """
        print(f"Downloading strategy from url {tarball_url}")
        resp = requests.get(tarball_url, allow_redirects=True)
        resp.raise_for_status()
        with open("/tmp/strategy", "wb") as file:
            file.write(resp.content)

        # copy_file_to_pod("freqtrade-0", "freqtrade", "/tmp/strategy", "/freqtrade/user_data/strategies")
        copy_file_to_pod("freqtrade-0", "freqtrade", "/tmp/strategy", "/tmp")
        return tarball_url

    tarball_url = get_latest_release()
    download_strategy(tarball_url, get_first_pod())


update_strategy_etl_dag = update_freqtrade_strategy_etl()
