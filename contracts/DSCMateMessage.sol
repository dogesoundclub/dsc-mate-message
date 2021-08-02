pragma solidity ^0.5.6;

import "./klaytn-contracts/token/KIP17/IKIP17Enumerable.sol";
import "./klaytn-contracts/ownership/Ownable.sol";
import "./klaytn-contracts/math/SafeMath.sol";
import "./interfaces/IDSCMateMessage.sol";

contract DSCMateMessage is Ownable, IDSCMateMessage {
    using SafeMath for uint256;

    uint256 public changeInterval = 86400;

    IKIP17Enumerable public mate;

    struct Record {
        address owner;
        string message;
        uint256 blockNumber;
    }
    mapping(uint256 => Record[]) public records;
    
    constructor(IKIP17Enumerable _mate) public {
        mate = _mate;
    }

    function setChangeInterval(uint256 interval) onlyOwner external {
        changeInterval = interval;
    }

    function set(uint256 mateId, string calldata message) external {
        require(mate.ownerOf(mateId) == msg.sender);
        Record[] storage rs = records[mateId];
        require(
            rs.length == 0 ||
            block.number - rs[rs.length - 1].blockNumber >= changeInterval
        );
        rs.push(Record({
            owner: msg.sender,
            message: message,
            blockNumber: block.number
        }));
        emit Set(mateId, msg.sender, message);
    }

    function recordCount(uint256 mateId) view external returns (uint256) {
        return records[mateId].length;
    }

    function record(uint256 mateId, uint256 index) view external returns (address owner, string memory message, uint256 blockNumber) {
        Record memory r = records[mateId][index];
        return (r.owner, r.message, r.blockNumber);
    }
}
