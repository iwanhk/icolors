from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            Random.deploy(addr(admin))
            SVG.deploy(addr(admin))
            ic = IColors.deploy(addr(admin))

            color1 = 255+120*1000+10*1000*1000
            color2 = 2 + 175*1000 + 255*1000*1000
            color3 = 175 + 100*1000 + 25*1000*1000

            ic.registerPublisher("HOBBY", "HOBBY is a community for yougth")
            ic.publish(['SPORTS', 'MUSIC'], [color1, color2], [25, 26])
            ic.publish(['SPORTS', 'ART'], [color1, color3], [25, 26])

            # test=testContract.deploy(addr(admin))

            ic.safeTransferFrom(admin, iwan, 0, 5, '', addr(admin))
            ic.safeTransferFrom(admin, iwan, 1, 5, '', addr(admin))

        if active_network in TEST_NETWORKS:
            if len(Random) == 0:
                Random.deploy(addr(admin))
            if len(SVG) == 0:
                SVG.deploy(addr(admin))

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
