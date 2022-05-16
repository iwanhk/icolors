from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            ic = iColorsNFT.deploy(addr(admin))

        if active_network in TEST_NETWORKS:
            i = iColors.deploy(addr(admin))
            ic = iColorsNFT.deploy(i, addr(admin))
            i.transferOwnership(ic, addr(admin))

            colorData, hobbyData, publisherData = loadData()

            amount = len(colorData)

            i.publish(publisherData[0]['publisher'], publisherData[0]['description'],
                      list(map(lambda x: int(x.replace('#', '0x'), 0),
                               list(colorData.keys()))),
                      [30000] * amount,
                      list(colorData.values()),
                      addr2(creator, 0.1*10**18))

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
