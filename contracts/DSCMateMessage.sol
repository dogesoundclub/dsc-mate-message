pragma solidity ^0.5.6;

import "./klaytn-contracts/token/KIP17/IKIP17Enumerable.sol";
import "./klaytn-contracts/ownership/Ownable.sol";
import "./klaytn-contracts/math/SafeMath.sol";
import "./interfaces/IDSCMateMessage.sol";
import "./interfaces/IDSCMateName.sol";

contract DSCMateMessage is Ownable, IDSCMateMessage {
    using SafeMath for uint256;

    uint256 public changeInterval = 86400;

    IKIP17Enumerable public mate;
    IDSCMateName public mateName;

    struct Record {
        address owner;
        string name;
        string message;
        uint256 blockNumber;
    }
    mapping(uint256 => Record[]) public records;
    
    constructor(
        IKIP17Enumerable _mate,
        IDSCMateName _mateName
    ) public {
        mate = _mate;
        mateName = _mateName;
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

        uint256 nameCount = mateName.recordCount(mateId);
        string memory name;
        if (nameCount == 0) {
            name = "";
        } else {
            (, name,) = mateName.record(mateId, nameCount - 1);
        }
        
        rs.push(Record({
            owner: msg.sender,
            name: name,
            message: message,
            blockNumber: block.number
        }));
        emit Set(mateId, msg.sender, name, message);
    }

    function recordCount(uint256 mateId) view external returns (uint256) {
        return records[mateId].length;
    }

    function record(uint256 mateId, uint256 index) view external returns (address owner, string memory name, string memory message, uint256 blockNumber) {
        Record memory r = records[mateId][index];
        return (r.owner, r.name, r.message, r.blockNumber);
    }
}
