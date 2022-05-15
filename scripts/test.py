from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            pass

        if active_network in TEST_NETWORKS:
            pass

    except Exception:
        console.print_exception()


if __name__ == "__main__":
    main()
