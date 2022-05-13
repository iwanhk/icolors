from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:

            Random.deploy(addr(admin))
            SVG.deploy(addr(admin))
            ic = iColorsNFT.deploy(addr(admin))

            color1 = 255+120*1000+10*1000*1000
            color2 = 2 + 175*1000 + 255*1000*1000
            color3 = 175 + 100*1000 + 25*1000*1000
            color4 = 200 + 123*1000 + 45*1000*1000

            tx = ic.publish("HOBBY", "HOBBY is a community for yougth",
                            [color1, color2],
                            ['SPORTS', 'MUSIC'],
                            [20, 25],
                            addr2(creator, 500))
            tx.wait(1)
            print(
                f"Address {tx.events[0]['from']} Fee: {tx.events[0]['fee']} , {tx.events[1]['count']} color(s)")

            tx = ic.publish('', '',
                            [color2, color3],
                            ['MUSIC', 'ART'],
                            [15, 45],
                            addr2(creator, 500))
            tx.wait(1)
            print(
                f"Address {tx.events[0]['from']} Fee: {tx.events[0]['fee']} , {tx.events[1]['count']} color(s)")

            tx = ic.publish("IWAN", "Iwan is a baobao",
                            [color4],
                            ['4'],
                            [45],
                            addr2(iwan, 500))
            tx.wait(1)
            print(
                f"Address {tx.events[0]['from']} Fee: {tx.events[0]['fee']} , {tx.events[1]['count']} color(s)")

            # test=testContract.deploy(addr(admin))

            # ic.safeTransferFrom(admin, iwan, 0, 5, '', addr(admin))
            # ic.safeTransferFrom(admin, iwan, 1, 5, '', addr(admin))

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
