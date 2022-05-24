from brownie import testContract, iColorsNFT, iColors, T721, ZlibDatabase, accounts, network, config
from scripts.tools import *
import os
import random
import zlib
from selenium import webdriver
import web3

D18 = 10**18
ZERO = '0x0000000000000000000000000000000000000000'
active_network = network.show_active()

LOCAL_NETWORKS = ['development', 'mainnet-fork', 'polygon-fork']
TEST_NETWORKS = ['rinkeby', 'bsc-test', 'mumbai']
REAL_NETWORKS = ['mainnet', 'polygon']
DEPLOYED_ADDR = {  # Deployed address of CivCityNFT CityToken
    'rinkeby': "",
    'mumbai': ""
}


def get_accounts(active_network):
    if active_network in LOCAL_NETWORKS:
        admin = accounts.add(config['wallets']['admin'])
        creator = accounts.add(config['wallets']['creator'])
        consumer = accounts.add(config['wallets']['consumer'])
        iwan = accounts.add(config['wallets']['iwan'])

        accounts[0].transfer(admin, "100 ether")
        accounts[1].transfer(creator, "100 ether")
        accounts[2].transfer(consumer, "100 ether")
        accounts[3].transfer(iwan, "100 ether")

    else:
        admin = accounts.add(config['wallets']['admin'])
        creator = accounts.add(config['wallets']['creator'])
        consumer = accounts.add(config['wallets']['consumer'])
        iwan = accounts.add(config['wallets']['iwan'])

    balance_alert(admin, "admin")
    balance_alert(creator, "creator")
    balance_alert(consumer, "consumer")
    balance_alert(iwan, "iwan")
    return [admin, creator, consumer, iwan]


def flat_contract(name: str, meta_data: dict) -> None:
    if not os.path.exists(name + '_flat'):
        os.mkdir(name + '_flat')

    with open(name + '_flat/settings.json', 'w') as f:
        json.dump(meta_data['standard_json_input']['settings'], f)

    for file in meta_data['standard_json_input']['sources'].keys():
        print(f"Flatten file {name+ '_flat/'+ file} ")
        with open(name + '_flat/' + file, 'w') as f:
            content = meta_data['standard_json_input']['sources'][file]['content'].split(
                '\n')

            for line in content:
                if 'import "' in line:
                    f.write(line.replace('import "', 'import "./')+'\n')
                else:
                    f.write(line+'\n')
            f.write(f'\n// Generated by {__file__} \n')


def chrome():
    options = webdriver.ChromeOptions()
    options.add_argument("disable-gpu")
    options.add_argument("disable-infobars")

    driver = webdriver.Chrome(options=options)
    return driver


def tx1(tx):
    tx.wait(1)
    for event in tx.events:
        if 'fee' in event:
            print(
                f"Address {event['from']} Fee: {event['fee']} , {event['count']} color(s)")


def tx2(tx):
    return
    tx.wait(1)
    print(tx.events)
    # print(f"{tx.events[1]['color']}({tx.events[1]['amount']}) minted, fee: {tx.events[1]['fee']}")


def tx3(tx):
    # return
    tx.wait(1)
    for event in tx.events:
        if 'color' in event:
            print(
                f"{event['color']}({event['amount']}) minted, fee: {event['fee']}")


def color():
    return random.randint(0, 255)+random.randint(0, 255) << 8+random.randint(0, 255) << 16


def toText(content):
    return web3.Web3.toText(content)


def inaccuracy(multiple: int, data: list):
    total = sum(data)
    width = 500*multiple//total

    sumup = 0
    for i in data:
        sumup += (i*width)//multiple

    return 500 - sumup


def deflate(data, compresslevel=9):
    compress = zlib.compressobj(
        compresslevel,        # level: 0-9
        zlib.DEFLATED,        # method: must be DEFLATED
        -zlib.MAX_WBITS,      # window size in bits:
        #   -15..-8: negate, suppress header
        #   8..15: normal
        #   16..30: subtract 16, gzip header
        zlib.DEF_MEM_LEVEL,   # mem level: 1..8/9
        0                     # strategy:
        #   0 = Z_DEFAULT_STRATEGY
        #   1 = Z_FILTERED
        #   2 = Z_HUFFMAN_ONLY
        #   3 = Z_RLE
        #   4 = Z_FIXED
    )
    deflated = compress.compress(data)
    deflated += compress.flush()
    return deflated


def loadData():
    with open('colors.json', 'r') as f:
        colorData = json.load(f)
    with open('hobbies.json', 'r') as f:
        hobbyData = json.load(f)
    with open('publisher.json', 'r') as f:
        publisherData = json.load(f)

    return (colorData, hobbyData, publisherData)
