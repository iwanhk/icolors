from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            ic = iColorsNFT.deploy(addr(admin))

            colorData, hobbyData, publisherData = loadData()

            amount = len(colorData)

            tx1(ic.publish(publisherData[0]['publisher'], publisherData[0]['description'],
                           list(map(lambda x: int(x.replace('#', '0x'), 0),
                                list(colorData.keys()))),
                           [20000] * amount,
                           list(colorData.values()),
                           addr2(creator, 0.1*10**18)))

            # Mint for iwan
            round = random.randint(1, 50)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(iwan, int(color.replace('#', '0x'), 0),
                            random.randint(1, 1), addr2(creator, 5000)))

            round = random.randint(1, 50)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(consumer, int(color.replace('#', '0x'), 0),
                            random.randint(1, 1), addr2(creator, 5000)))

            round = random.randint(1, 50)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(admin, int(color.replace('#', '0x'), 0),
                            random.randint(1, 1), addr2(creator, 5000)))

        if active_network in TEST_NETWORKS:
            ic = iColorsNFT[-1]
            colorData, hobbyData, publisherData = loadData()

            # Mint for iwan
            round = random.randint(1, 5)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                ic.mint(iwan, int(color.replace('#', '0x'), 0),
                        random.randint(1, 3), addr2(creator, 5000))

            round = random.randint(1, 5)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                ic.mint(consumer, int(color.replace('#', '0x'), 0),
                        random.randint(1, 3), addr2(creator, 5000))

            round = random.randint(1, 5)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                ic.mint(admin, int(color.replace('#', '0x'), 0),
                        random.randint(1, 3), addr2(creator, 5000))
    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
