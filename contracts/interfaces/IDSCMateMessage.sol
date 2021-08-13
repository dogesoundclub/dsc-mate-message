pragma solidity ^0.5.6;

interface IDSCMateMessage {
    
    event Set(uint256 indexed mateId, address indexed owner, string name, string message);

    function changeInterval() view external returns (uint256);
    function set(uint256 mateId, string calldata message) external;
    function recordCount(uint256 mateId) view external returns (uint256);
    function record(uint256 mateId, uint256 index) view external returns (address owner, string memory name, string memory message, uint256 blockNumber);
}
