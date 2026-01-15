// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IForwarder
 * @notice Interface for EIP-2771 compatible forwarder
 */
interface IForwarder {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }

    /**
     * @notice Verify a forward request signature
     * @param req The forward request
     * @param signature The signature to verify
     * @return true if signature is valid
     */
    function verify(ForwardRequest calldata req, bytes calldata signature) external view returns (bool);

    /**
     * @notice Execute a forward request
     * @param req The forward request
     * @param signature The signature
     * @return success Whether execution succeeded
     * @return ret The return data
     */
    function execute(ForwardRequest calldata req, bytes calldata signature)
        external
        payable
        returns (bool success, bytes memory ret);
}

