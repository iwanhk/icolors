from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            data = ZlibDatabase.deploy(addr(admin))
            i = iColors.deploy(data, addr(admin))
            ic = iColorsNFT.deploy(i, addr(admin))
            i.transferOwnership(ic, addr(admin))

        if active_network in TEST_NETWORKS:
            ic = iColorsNFT[-1]
            i = iColors[-1]
            data = ZlibDatabase[-1]

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
