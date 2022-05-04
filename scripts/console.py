from scripts.functions import *

def main():
    active_network= network.show_active()
    print("Current Network:"+ active_network)

    admin, creator, consumer, iwan= get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            Random.deploy(addr(admin))
            SVG.deploy(addr(admin))
            ic= IColors.deploy(addr(admin))

            ic.registerPublisher("HOBBY", "HOBBY is a community for yougth")
            ic.publish(['SPORTS', 'MUSIC'], ["chartreuse", "crimson"], [25, 26])
            ic.publish(['SPORTS', 'ART'], ["chartreuse", "cornsilk"], [25, 26])

            #test=testContract.deploy(addr(admin))

        if active_network in TEST_NETWORKS:
            if len(Random)==0:
                Random.deploy(addr(admin))
            if len(SVG)==0:    
                SVG.deploy(addr(admin))

    except Exception:
        console.print_exception()
        # Test net contract address

if __name__=="__main__":
    main()