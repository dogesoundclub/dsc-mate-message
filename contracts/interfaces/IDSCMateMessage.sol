pragma solidity ^0.5.6;

interface IDSCMateMessage {
    
    event Set(address indexed owner, uint256 indexed mateId, string message);
    
    function messages(uint256 mateId) view external returns (string memory);
    function set(uint256 mateId, string calldata message) external;
}
