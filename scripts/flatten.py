from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        iColorsNFT.deploy(addr(admin))

        flat_contract('iColorsNFT', iColorsNFT.get_verification_info())

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
