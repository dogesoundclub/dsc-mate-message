pragma solidity ^0.5.6;

interface IDSCMateName {
    
    event Set(uint256 indexed mateId, address indexed owner, string name);
    
    function tokenAmountForChanging() view external returns (uint256);
    function exists(string calldata name) view external returns (bool);
    function set(uint256 mateId, string calldata name) external;
    function recordCount(uint256 mateId) view external returns (uint256);
    function record(uint256 mateId, uint256 index) view external returns (address owner, string memory name, uint256 blockNumber);
    function getName(uint256 mateId) view external returns (string memory name);
}
