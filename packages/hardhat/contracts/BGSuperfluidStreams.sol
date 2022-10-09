pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

// import "@openzeppelin/contracts/access/Ownable.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

import {
    ISuperfluid
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol"; //"@superfluid-finance/ethereum-monorepo/packages/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import {
    IConstantFlowAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

import {
    CFAv1Library
} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";

import {
    ISuperfluidToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluidToken.sol";

interface SuperETH {
    function upgradeByETH() payable external;
    function downgradeToETH(uint256) external;
}


contract BGSuperfluidStreams {
    event Withdraw(address indexed to, uint256 amount, string reason);

    address constant superTokenAddress = 0x5943F705aBb6834Cad767e6E4bB258Bc48D9C947;
    SuperETH public superEthToken = SuperETH(superTokenAddress);
    CFAv1Library.InitData public cfaV1;

    struct BuilderStreamInfo {
        uint256 cap;
        uint256 last;
    }
    mapping(address => BuilderStreamInfo) public streamedBuilders;

    uint256 public frequency = 2592000; // 30 days
    uint256 public totalCap;
    uint256 public totalStreams;
    uint256 public totalMonthlyWithdrawn;

    constructor(ISuperfluid host) {
        // initialize InitData struct, and set equal to cfaV1
        cfaV1 = CFAv1Library.InitData(
            host,
        // here, we are deriving the address of the CFA using the host contract
            IConstantFlowAgreementV1(
                address(host.getAgreementClass(
                    keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1")
                ))
            )
        );

        // flowrate = 1wei/second (we want to be an empty stream)
        cfaV1.cfa.createFlow(ISuperfluidToken(superTokenAddress), address(this), 1, '');
    }

    function unlockedBuilderAmount(address _builder) public view returns (uint256) {
        BuilderStreamInfo memory builderStream = streamedBuilders[_builder];
        require(builderStream.cap > 0, "No active stream for builder");

        if (block.timestamp - builderStream.last > frequency) {
            return builderStream.cap;
        }

        return (builderStream.cap * (block.timestamp - builderStream.last)) / frequency;
    }

    function addBuilderStream(address payable _builder, uint256 _cap) public payable {
        require(msg.value == _cap, "Not enough");
        streamedBuilders[_builder] = BuilderStreamInfo(_cap, block.timestamp - frequency);
        totalCap += _cap;
        totalStreams += 1;
        superEthToken.upgradeByETH{value: msg.value}();
    }

    function streamWithdraw(uint256 _amount, string memory _reason) public {
        BuilderStreamInfo storage builderStream = streamedBuilders[msg.sender];
        require(builderStream.cap > 0, "No active stream for builder");

        uint256 totalAmountCanWithdraw = unlockedBuilderAmount(msg.sender);
        require(totalAmountCanWithdraw >= _amount,"not enough in the stream");

        uint256 cappedLast = block.timestamp - frequency;
        if (builderStream.last < cappedLast){
            builderStream.last = cappedLast;
        }

        builderStream.last = builderStream.last + ((block.timestamp - builderStream.last) * _amount / totalAmountCanWithdraw);

        superEthToken.downgradeToETH(_amount);

        (bool sent,) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        emit Withdraw(msg.sender, _amount, _reason);
        totalMonthlyWithdrawn += _amount;

        uint256 newWeiPerSec = totalMonthlyWithdrawn / 2592000;
        cfaV1.cfa.updateFlow(ISuperfluidToken(superTokenAddress), address(this), int96(int(newWeiPerSec)), '');
    }

    function resetSuperfluidFlowRate() public {
        cfaV1.cfa.updateFlow(ISuperfluidToken(superTokenAddress), address(this), 1, '');
        totalMonthlyWithdrawn = 0;
    }

    function deposit() public payable {
        superEthToken.upgradeByETH{value: msg.value}();
    }

    // to support receiving ETH by default
    receive() external payable {}
    fallback() external payable {}
}
