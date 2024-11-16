# CLM-on-Ekubo

The goal of the protocol is to optimize the management of Liquidity Provider (LP) positions on EKUBO, a Concentrated Automated Market Maker (CAMM) Decentralized Exchange (DEX) built on Starknet.

This project uses the [github.com/EkuboProtocol/abis](https://github.com/EkuboProtocol/abis) for interacting with EKUBO.
It leverages the [github.com/OpenZeppelin/cairo-contracts](https://github.com/OpenZeppelin/cairo-contracts) library.

Not enough time for the front and back end, but I would use [github.com/EkuboProtocol/rust-sdk](https://github.com/EkuboProtocol/rust-sdk) and [uniswapv3book.com/milestone_2/user-interface.html](https://uniswapv3book.com/milestone_2/user-interface.html). 


**Features:**

- Simplified User Experience: Users are manually selecting tick ranges. Instead, they simply provide the two underlying assets they wish to pair.

- Automated Compound Fee Harvesting: The protocol continuously monitors and harvests fees on behalf of the user, ensuring maximum revenue capture without manual intervention.

- Dynamic Position Management: The protocol automatically updates liquidity position


