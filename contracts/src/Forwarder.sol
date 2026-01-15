// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IForwarder} from "./interfaces/IForwarder.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/**
 * @title Forwarder
 * @notice EIP-2771 compatible forwarder for meta-transactions
 * @dev Allows relayer to execute transactions on behalf of users
 */
contract Forwarder is IForwarder, EIP712 {
    using ECDSA for bytes32;

    bytes32 private constant FORWARD_REQUEST_TYPEHASH =
        keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

    mapping(address => uint256) private _nonces;

    constructor() EIP712("BaseRelayer", "1") {}

    /**
     * @notice Get the current nonce for an address
     * @param from The address to get nonce for
     * @return The current nonce
     */
    function getNonce(address from) external view returns (uint256) {
        return _nonces[from];
    }

    /**
     * @notice Verify a forward request signature
     * @param req The forward request
     * @param signature The signature to verify
     * @return true if signature is valid
     */
    function verify(ForwardRequest calldata req, bytes calldata signature) external view override returns (bool) {
        address signer = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    FORWARD_REQUEST_TYPEHASH,
                    req.from,
                    req.to,
                    req.value,
                    req.gas,
                    req.nonce,
                    keccak256(req.data)
                )
            )
        ).recover(signature);

        return signer == req.from && req.nonce == _nonces[req.from];
    }

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
        override
        returns (bool success, bytes memory ret)
    {
        // Verify signature
        require(this.verify(req, signature), "Forwarder: invalid signature");

        // Check nonce
        require(req.nonce == _nonces[req.from], "Forwarder: nonce mismatch");

        // Increment nonce
        _nonces[req.from]++;

        // Execute call
        (success, ret) = req.to.call{value: req.value, gas: req.gas}(req.data);

        // Refund unused gas
        if (msg.value > req.value) {
            payable(msg.sender).transfer(msg.value - req.value);
        }

        return (success, ret);
    }
}

