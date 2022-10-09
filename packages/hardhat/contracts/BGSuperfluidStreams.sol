pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

// import "@openzeppelin/contracts/access/Ownable.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract BGSuperfluidStreams {
    event Withdraw(address indexed to, uint256 amount, string reason);


    struct BuilderStreamInfo {
        uint256 cap;
        uint256 frequency;
        uint256 last;
    }

    mapping(address => BuilderStreamInfo) public streamedBuilders;

    constructor() payable {
    }

    function streamBalance(address _builder) public view returns (uint256) {
        BuilderStreamInfo memory builderStream = streamedBuilders[_builder];
        require(builderStream.cap > 0, "No active stream for builder");

        if (block.timestamp - builderStream.last > builderStream.frequency) {
            return builderStream.cap;
        }

        return (builderStream.cap * (block.timestamp - builderStream.last)) / builderStream.frequency;
    }

    function addBuilderStream(address payable _builder, uint256 _cap, uint256 _frequency) public {
        streamedBuilders[_builder] = BuilderStreamInfo(_cap, _frequency, block.timestamp - _frequency);
    }

    function streamWithdraw(uint256 _amount, string memory _reason) public {
        BuilderStreamInfo memory builderStream = streamedBuilders[msg.sender];
        require(builderStream.cap > 0, "No active stream for builder");

        uint256 totalAmountCanWithdraw = streamBalance(msg.sender);
        require(totalAmountCanWithdraw >= _amount,"not enough in the stream");

        uint256 cappedLast = block.timestamp - builderStream.frequency;
        if (builderStream.last < cappedLast){
            builderStream.last = cappedLast;
        }

        builderStream.last = builderStream.last + ((block.timestamp - builderStream.last) * _amount / totalAmountCanWithdraw);
        emit Withdraw(msg.sender, _amount, _reason);

        (bool sent,) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    // to support receiving ETH by default
    receive() external payable {}
    fallback() external payable {}
}
