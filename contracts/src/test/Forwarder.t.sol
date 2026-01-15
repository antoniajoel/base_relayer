// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Forwarder} from "../Forwarder.sol";
import {IForwarder} from "../interfaces/IForwarder.sol";

contract ForwarderTest is Test {
    Forwarder public forwarder;
    address public user = address(0x1);
    address public target = address(0x2);
    uint256 private userPrivateKey = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;

    function setUp() public {
        forwarder = new Forwarder();
        vm.deal(user, 10 ether);
    }

    function testGetNonce() public {
        uint256 nonce = forwarder.getNonce(user);
        assertEq(nonce, 0);
    }

    function testVerifySignature() public {
        IForwarder.ForwardRequest memory req = IForwarder.ForwardRequest({
            from: user,
            to: target,
            value: 1 ether,
            gas: 100000,
            nonce: 0,
            data: abi.encodeWithSignature("test()")
        });

        bytes memory signature = _signRequest(req, userPrivateKey);
        bool isValid = forwarder.verify(req, signature);
        assertTrue(isValid);
    }

    function testExecuteTransaction() public {
        // Deploy a simple test contract
        TestTarget testTarget = new TestTarget();
        target = address(testTarget);

        IForwarder.ForwardRequest memory req = IForwarder.ForwardRequest({
            from: user,
            to: target,
            value: 1 ether,
            gas: 100000,
            nonce: 0,
            data: abi.encodeWithSignature("setValue(uint256)", 42)
        });

        bytes memory signature = _signRequest(req, userPrivateKey);

        vm.prank(address(0x3)); // Relayer
        vm.deal(address(0x3), 10 ether);
        (bool success, ) = address(forwarder).call{value: 1 ether}(
            abi.encodeWithSelector(Forwarder.execute.selector, req, signature)
        );

        assertTrue(success);
        assertEq(testTarget.value(), 42);
        assertEq(forwarder.getNonce(user), 1);
    }

    function testNonceIncrement() public {
        IForwarder.ForwardRequest memory req = IForwarder.ForwardRequest({
            from: user,
            to: target,
            value: 0,
            gas: 100000,
            nonce: 0,
            data: ""
        });

        bytes memory signature = _signRequest(req, userPrivateKey);

        vm.prank(address(0x3));
        forwarder.execute(req, signature);

        assertEq(forwarder.getNonce(user), 1);

        req.nonce = 1;
        signature = _signRequest(req, userPrivateKey);

        vm.prank(address(0x3));
        forwarder.execute(req, signature);

        assertEq(forwarder.getNonce(user), 2);
    }

    function _signRequest(IForwarder.ForwardRequest memory req, uint256 privateKey) internal view returns (bytes memory) {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("BaseRelayer"),
                keccak256("1"),
                block.chainid,
                address(forwarder)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)"),
                req.from,
                req.to,
                req.value,
                req.gas,
                req.nonce,
                keccak256(req.data)
            )
        );

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);
        return abi.encodePacked(r, s, v);
    }
}

contract TestTarget {
    uint256 public value;

    function setValue(uint256 _value) external payable {
        value = _value;
    }

    function test() external pure returns (bool) {
        return true;
    }
}

