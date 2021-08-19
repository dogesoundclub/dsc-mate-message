pragma solidity ^0.5.6;

import "./klaytn-contracts/token/KIP17/IKIP17Enumerable.sol";
import "./klaytn-contracts/token/KIP7/KIP7Burnable.sol";
import "./klaytn-contracts/ownership/Ownable.sol";
import "./klaytn-contracts/math/SafeMath.sol";
import "./interfaces/IDSCMateName.sol";

contract DSCMateName is Ownable, IDSCMateName {
    using SafeMath for uint256;

    IKIP17Enumerable public mate;
    KIP7Burnable public token;
    uint256 public tokenAmountForChanging = 100 * 1e18;

    struct Record {
        address owner;
        string name;
        uint256 blockNumber;
    }
    mapping(uint256 => Record[]) public records;
    mapping(string => bool) public _exists;

    constructor(IKIP17Enumerable _mate) public {
        mate = _mate;
    }

    function setToken(KIP7Burnable _token) onlyOwner external {
        token = _token;
    }

    function setTokenAmountForChanging(uint256 amount) onlyOwner external {
        tokenAmountForChanging = amount;
    }

    function exists(string calldata name) view external returns (bool) {
        return _exists[name];
    }

    function set(uint256 mateId, string calldata name) external {
        require(mate.ownerOf(mateId) == msg.sender);
        require(_exists[name] != true);

        Record[] storage rs = records[mateId];
        uint256 length = rs.length;
        if (length != 0) {
            if (address(token) != address(0)) {
                token.burnFrom(msg.sender, tokenAmountForChanging);
            }
            _exists[rs[length - 1].name] = false;
        }

        rs.push(Record({
            owner: msg.sender,
            name: name,
            blockNumber: block.number
        }));
        _exists[name] = true;
        emit Set(mateId, msg.sender, name);
    }

    function recordCount(uint256 mateId) view external returns (uint256) {
        return records[mateId].length;
    }

    function record(uint256 mateId, uint256 index) view external returns (address owner, string memory name, uint256 blockNumber) {
        Record memory r = records[mateId][index];
        return (r.owner, r.name, r.blockNumber);
    }

    function getName(uint256 mateId) view external returns (string memory name) {
        uint256 length = records[mateId].length;
        if (length == 0) {
            return "";
        }
        Record memory r = records[mateId][length.sub(1)];
        return r.name;
    }
}
