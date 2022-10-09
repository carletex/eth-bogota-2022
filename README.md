#  🚀 Contributor Streams 

Payment system for organizations to pay contributors based on contributions in a recurring way. 

View the slides [here]( https://www.canva.com/design/DAFOis836EY/9T-DWlBAju3k3V7gBIUCGA/edit?utm_content=DAFOis836EY&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton).

## Overview

This projects aims to provide a solution to DAO's to pay contributors based on contributions. 

Here's how the contributor streams work:
- Pay contributors based on contributions
- Contributors can go & come back to the same stream
- Stream contract is funded based on withdrawn amounts thats adjusted dynamically
- Salary & Contribution Transparency

## Tools Used
- **Scaffold-eth:** provides fast prototyping
- **Superfluid:** money streaming to the DAO contract in Supertokens.
- **Wallet connect:** web3 login, users can login to the website and withdraw. Contributors will have to make a transaction where they provide the work and the money they are withdrawing for it.
- **ENS:** web3 identity.
- **Optimisim & Polygon:** deployed to the networks

## Quick Start

Prerequisites: [Node (v16 LTS)](https://nodejs.org/en/download/) plus [Yarn (v1.x)](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

> clone/fork the repo:

```bash
git clone https://github.com/carletex/eth-bogota-2022.git
```

> install and start your 👷‍ Hardhat chain:

```bash
cd eth-bogota-2022
yarn install
yarn chain
```

> in a second terminal window, start your 📱 frontend:

```bash
cd eth-bogota-2022
yarn start
```

> in a third terminal window, 🛰 deploy your contract:

```bash
cd eth-bogota-2022
yarn deploy
```

🔏 View the smart contract `BGSuperfluidStreams.sol` in `packages/hardhat/contracts`

---


This project was built for ETH Bogota Hackathon! 
