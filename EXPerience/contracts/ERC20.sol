// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./ERC165Storage.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/extensions/IERC20Metadata.sol";
import "./utils/Context.sol";

/// @dev Taken from : OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)
/// @dev Update ERC20 contract to support Soul-bounding, once assigned - cannot be transferred 

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */

 // Context : retrieval of msg.sender and msg.data 
 // ERC165 : Implementation of supportsInterface(byte4) 
 // IERC165 : supportsInterface(byte4) external view 
 // ERC165Storage : local introspection, interface storage registry
 // IERC20Metadata : External functions of _name, _symbol, _decimal
 // Keeping decimals fixed at 18

contract ERC20 is Context, ERC165Storage, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    // Revert error OperationNotAllowed when user tries to perform restricted actions, transfer - transferFrom - approve etc.
    // Using custom error is much cheaper than revert with a string description.
    error OperationNotAllowed();
    // Revert error for unsupported actions
    error UnsupportedAction();
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        // _register interfaces that this contract is supporting 
        // So far ERC20 has IERC20 interface and ERC20Metadata interface support
        _registerInterface(type(IERC20).interfaceId);
        _registerInterface(type(IERC20Metadata).interfaceId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Storage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Restricted
     */
    function transfer(address, uint256) public virtual override returns (bool) {
        revert OperationNotAllowed();
    }

    /**
     * @dev See {IERC20-allowance}.
     *
     * Unsupported
     */
    function allowance(address, address) public view virtual override returns (uint256) {
        revert UnsupportedAction();
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Restricted 
     */
    function approve(address, uint256) public virtual override returns (bool) {
        revert OperationNotAllowed();
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Restricted
     */
    function transferFrom(address, address, uint256) public virtual override returns (bool) {
        revert OperationNotAllowed();
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * Unsupported
     */
    function increaseAllowance(address, uint256) public virtual returns (bool) {
        revert UnsupportedAction();
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * Unsupported
     */
    function decreaseAllowance(address, uint256) public virtual returns (bool) {
        revert UnsupportedAction();
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "EXPToken (Mint): Mint to Add(0) - X");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * 
     * Changes:
     *
     * - Remove require, instead revert with custom error to save gas
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "EXPToken (Burn): Burn from Add(0) - X.");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "EXPToken (Burn): Insufficient balance.");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * Restricted
     */
    function _approve(address, address, uint256) internal virtual {
        //revert OperationNotAllowed();
        revert();
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
