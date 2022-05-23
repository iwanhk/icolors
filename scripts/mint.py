from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            i = iColors.deploy(addr(admin))
            ic = iColorsNFT.deploy(i, addr(admin))
            i.transferOwnership(ic, addr(admin))

            colorData, hobbyData, publisherData = loadData()

            amount = len(colorData)

            tx1(i.publish(publisherData[0]['publisher'], publisherData[0]['description'],
                          list(map(lambda x: int(x.replace('#', '0x'), 0),
                               list(colorData.keys()))),
                          [30000] * amount,
                hobbyData,
                addr2(creator, 0.1*10**18)))

            # Mint for iwan
            round = random.randint(1, 50)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(iwan, int(color.replace('#', '0x'), 0),
                            random.randint(1, 15), addr2(creator, 5000)))

            round = random.randint(1, 50)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(consumer, int(color.replace('#', '0x'), 0),
                            random.randint(1, 15), addr2(creator, 5000)))

            round = random.randint(1, 50)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(admin, int(color.replace('#', '0x'), 0),
                            random.randint(1, 15), addr2(creator, 5000)))

            t721 = T721.deploy(addr(admin))

            t721.approve(ic, 0, addr(admin))
            t721.approve(ic, 1, addr(admin))
            t721.approve(ic, 2, addr(admin))

            ic.dockAsset(0, t721, 0, addr(admin))
            ic.dockAsset(1, t721, 1, addr(admin))
            ic.dockAsset(2, t721, 2, addr(admin))

        if active_network in TEST_NETWORKS:
            ic = iColorsNFT[-1]
            colorData, hobbyData, publisherData = loadData()

            # Mint for iwan
            round = random.randint(1, 5)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(iwan, int(color.replace('#', '0x'), 0),
                            random.randint(1, 3), addr2(creator, 5000)))

            round = random.randint(1, 5)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(consumer, int(color.replace('#', '0x'), 0),
                            random.randint(1, 3), addr2(creator, 5000)))

            round = random.randint(1, 5)
            for r in range(round):
                color = random.choice(list(colorData.keys()))
                tx3(ic.mint(admin, int(color.replace('#', '0x'), 0),
                            random.randint(1, 3), addr2(creator, 5000)))

            t721 = T721.deploy(addr(admin))

            t721.approve(ic, 0, addr(admin))
            t721.approve(ic, 1, addr(admin))
            t721.approve(ic, 2, addr(admin))

            ic.dockAsset(0, t721, 0, addr(admin))
            ic.dockAsset(1, t721, 1, addr(admin))
            ic.dockAsset(2, t721, 2, addr(admin))

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
