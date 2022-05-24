from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            pass

        if active_network in TEST_NETWORKS:
            data = DataTemplate[-1]
            with open('animation.svg', 'r') as f:
                buffer = f.read()
                compress_data = deflate(str.encode(buffer))
                print(
                    f"animation.svg ({len(buffer)}) compressed to {len(compress_data)}")
                data.update(0, compress_data, len(buffer), addr(admin))

            print(f"{len(data.get(0))} bytes uploaded to dataTemplate")

    except Exception:
        console.print_exception()


if __name__ == "__main__":
    main()
