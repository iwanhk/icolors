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

            names = loadCSV('isotop.csv')
            colors = []
            for i in range(len(names)):
                colors.append(randColor())

            ic.setPrice(0, 0)
            iso = isotop.deploy(ic, colors, names, addr2(admin, 0))
            tt = T721.deploy(iso, addr(admin))

            with open('animation.svg', 'r') as f:
                buffer = f.read()
                compress_data = deflate(str.encode(buffer))
                print(
                    f"animation.svg ({len(buffer)}) compressed to {len(compress_data)}")
                data.store('iColors.NFT', compress_data, len(buffer))

            print(f"{len(data.get('iColors.NFT'))} bytes uploaded to ZlibDatabase")

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
