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

    function remainBlocks(uint256 mateId) view external returns (uint256) {
        Record[] memory rs = records[mateId];
        if (rs.length == 0) {
            return 0;
        } else {
            uint256 blocks = block.number.sub(rs[rs.length.sub(1)].blockNumber);
            if (blocks >= changeInterval) {
                return 0;
            } else {
                return changeInterval.sub(blocks);
            }
        }
    }

    function set(uint256 mateId, string calldata message) external {
        require(mate.ownerOf(mateId) == msg.sender);
        Record[] storage rs = records[mateId];
        require(
            rs.length == 0 ||
            block.number.sub(rs[rs.length.sub(1)].blockNumber) >= changeInterval
        );

        uint256 nameCount = mateName.recordCount(mateId);
        string memory name;
        if (nameCount == 0) {
            name = "";
        } else {
            (, name,) = mateName.record(mateId, nameCount.sub(1));
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

    function lastMessage(uint256 mateId) view external returns (string memory message) {
        uint256 length = records[mateId].length;
        if (length == 0) {
            return "";
        }
        Record memory r = records[mateId][length.sub(1)];
        return r.message;
    }
}
