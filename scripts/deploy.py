from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            ic = iColorsNFT.deploy(addr(admin))

        if active_network in TEST_NETWORKS:
            data = ZlibDatabase.deploy(addr(admin))
            i = iColors.deploy(data, addr(admin))
            ic = iColorsNFT.deploy(i, addr(admin))
            i.transferOwnership(ic, addr(admin))

            colorData, hobbyData, publisherData = loadData()

            amount = len(colorData)

            i.publish(publisherData[0]['publisher'], publisherData[0]['description'],
                      list(map(lambda x: int(x.replace('#', '0x'), 0),
                               list(colorData.keys()))),
                      [30000] * amount,
                      hobbyData,
                      addr2(creator, 0.1*10**18))

            T721.deploy(addr(admin))

            with open('animation.svg', 'r') as f:
                buffer = f.read()
                compress_data = deflate(str.encode(buffer))
                print(
                    f"animation.svg ({len(buffer)}) compressed to {len(compress_data)}")
                data.store('astronaut-1', compress_data, len(buffer))

            print(f"{len(data.get('astronaut-1'))} bytes uploaded to ZlibDatabase")

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
