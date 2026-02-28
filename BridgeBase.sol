// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

interface IBridgeToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

contract CrossChainBridge is AccessControl, Pausable {
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");
    IBridgeToken public immutable token;

    mapping(bytes32 => bool) public processedTransactions;

    event BridgeInitiated(address indexed user, uint256 amount, uint256 nonce, uint256 timestamp);
    event BridgeFinalized(address indexed user, uint256 amount, uint256 nonce, bytes32 txHash);

    constructor(address _token, address _admin) {
        token = IBridgeToken(_token);
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    /**
     * @dev Step 1: User burns tokens on Source Chain to move them.
     */
    function bridgeTokens(uint256 _amount, uint256 _nonce) external whenNotPaused {
        token.burn(msg.sender, _amount);
        emit BridgeInitiated(msg.sender, _amount, _nonce, block.timestamp);
    }

    /**
     * @dev Step 2: Relayer calls this on Destination Chain after verifying source event.
     */
    function finalizeBridge(
        address _user,
        uint256 _amount,
        uint256 _nonce,
        bytes32 _sourceTxHash
    ) external onlyRole(RELAYER_ROLE) whenNotPaused {
        bytes32 txKey = keccak256(abi.encodePacked(_user, _amount, _nonce, _sourceTxHash));
        require(!processedTransactions[txKey], "Transaction already processed");

        processedTransactions[txKey] = true;
        token.mint(_user, _amount);

        emit BridgeFinalized(_user, _amount, _nonce, _sourceTxHash);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
