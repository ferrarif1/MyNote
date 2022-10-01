// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev ERC20 
 */
interface IERC20 {
    /**
     * @dev `value`  (`from`) (`to`)
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev `value` (`owner`)    (`spender`)
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev supply
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev account
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev  `amount`  `to`
     *
     * `true`.
     *
     * {Transfer} 
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev `owner`  `spender`
     *
     * {approve} {transferFrom} ，`allowance`
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev   `spender`   `amount`
     *
     * `true`.
     *
     *  {Approval} 
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * approval
     *
     * `true`.
     *
     *  {Transfer} 
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}