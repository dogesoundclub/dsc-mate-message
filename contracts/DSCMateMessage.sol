pragma solidity ^0.5.6;

import "./klaytn-contracts/token/KIP17/IKIP17Enumerable.sol";
import "./klaytn-contracts/math/SafeMath.sol";
import "./interfaces/IDSCMateMessage.sol";

contract DSCMateMessage is IDSCMateMessage {
    using SafeMath for uint256;

    uint256 public constant CHANGE_INTERVAL = 86400;

    IKIP17Enumerable public mate;
    
    mapping(uint256 => string) public messages;
    mapping(uint256 => mapping(address => uint256)) public lastChangeBlocks;
    
    constructor(IKIP17Enumerable _mate) public {
        mate = _mate;
    }

    function set(uint256 mateId, string calldata message) external {
        require(mate.ownerOf(mateId) == msg.sender);
        require(block.number - lastChangeBlocks[mateId][msg.sender] >= CHANGE_INTERVAL);
        lastChangeBlocks[mateId][msg.sender] = block.number;
        messages[mateId] = message;
        emit Set(msg.sender, mateId, message);
    }
}
