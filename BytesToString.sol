// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// https://stackoverflow.com/questions/67893318/solidity-how-to-represent-bytes32-as-string

contract Bytes32ToString {
    function toHex16(bytes16 data) internal pure returns (bytes32 result) {
        result =
            (bytes32(data) &
                0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000) |
            ((bytes32(data) &
                0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >>
                64);
        result =
            (result &
                0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000) |
            ((result &
                0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >>
                32);
        result =
            (result &
                0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000) |
            ((result &
                0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >>
                16);
        result =
            (result &
                0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000) |
            ((result &
                0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >>
                8);
        result =
            ((result &
                0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >>
                4) |
            ((result &
                0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >>
                8);
        result = bytes32(
            0x3030303030303030303030303030303030303030303030303030303030303030 +
                uint256(result) +
                (((uint256(result) +
                    0x0606060606060606060606060606060606060606060606060606060606060606) >>
                    4) &
                    0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) *
                7
        );
    }

    function toHex(bytes32 data) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "0x",
                    toHex16(bytes16(data)),
                    toHex16(bytes16(data << 128))
                )
            );
    }

    function toHex3(bytes3 data) public view returns (string memory output) {
        bytes6 result = (bytes6(data) & 0xFFF000000000) | // 0x123456
                ((bytes6(data) & 0x000FFF000000) >> 12);
        result = (result & 0xFF0000FF0000) | ((result & 0x00F00000F000) >> 8); // 0x123000456000
        result = (result & 0xF000F0F000F0) | ((result & 0x0F00000F0000) >> 4); // 0x120030450060
        result = (result & 0xF0F0F0F0F0F0) >> 4; // 0x102030405060
        result = bytes6(
            0x303030303030 +
                uint48(result) +
                (((uint48(result) + 0x060606060606) >> 4) & 0x0F0F0F0F0F0F) *
                7
        );
        // result = bytes6(0x303030303030 + uint48(result));
        output = string(abi.encodePacked(result));
    }
}
