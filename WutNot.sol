// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts@5.5.0/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts@5.5.0/token/ERC20/ERC20.sol";
import {ERC20Pausable} from "@openzeppelin/contracts@5.5.0/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts@5.5.0/token/ERC20/extensions/ERC20Permit.sol";

contract CWN is ERC20, ERC20Pausable, Ownable, ERC20Permit {
    address public uniswapV2Pair;
        bool public tradingEnabled;
            bool public antiBotActive;
                uint256 public antiBotEndBlock;
                    mapping(address => uint256) public lastBuyBlock;

                        uint256 public constant COOLDOWN_BLOCKS = 30;
                            uint256 public constant MAX_BUY_AMOUNT = 150000000 * 10 ** 18;
                                uint256 public constant MAX_WALLET_AMOUNT = 1000000000 * 10 ** 18;

                                    // Events
                                        event UniswapV2PairSet(address indexed pair);
                                            event TradingEnabled(uint256 startBlock, uint256 endBlock);
                                                event AntiBotDisabled();

                                                    constructor(address recipient, address initialOwner)
                                                            ERC20("C - W", "WN")
                                                                    Ownable(initialOwner)
                                                                            ERC20Permit("C - W")
                                                                                {
                                                                                        _mint(recipient, 100000000000 * 10 ** decimals());
                                                                                            }

                                                                                                function pause() public onlyOwner {
                                                                                                        _pause();
                                                                                                            }

                                                                                                                function unpause() public onlyOwner {
                                                                                                                        _unpause();
                                                                                                                            }

                                                                                                                                function setUniswapV2Pair(address _pair) external onlyOwner {
                                                                                                                                        uniswapV2Pair = _pair;
                                                                                                                                                emit UniswapV2PairSet(_pair);
                                                                                                                                                    }

                                                                                                                                                        function enableTrading() external onlyOwner {
                                                                                                                                                                require(!tradingEnabled, "Trading already enabled");
                                                                                                                                                                        tradingEnabled = true;
                                                                                                                                                                                antiBotActive = true;
                                                                                                                                                                                        antiBotEndBlock = block.number + 1080;
                                                                                                                                                                                                if (paused()) _unpause();
                                                                                                                                                                                                        emit TradingEnabled(block.number, antiBotEndBlock);
                                                                                                                                                                                                            }

                                                                                                                                                                                                                function disableAntiBot() external onlyOwner {
                                                                                                                                                                                                                        antiBotActive = false;
                                                                                                                                                                                                                                emit AntiBotDisabled();
                                                                                                                                                                                                                                    }

                                                                                                                                                                                                                                        function _update(address from, address to, uint256 value)
                                                                                                                                                                                                                                                internal
                                                                                                                                                                                                                                                        override(ERC20, ERC20Pausable)
                                                                                                                                                                                                                                                            {
                                                                                                                                                                                                                                                                    if (!tradingEnabled) {
                                                                                                                                                                                                                                                                                require(from == owner() || to == owner(), "Trading not enabled");
                                                                                                                                                                                                                                                                                        }

                                                                                                                                                                                                                                                                                                // Anti-bot only on buys from the pair
                                                                                                                                                                                                                                                                                                        if (from == uniswapV2Pair && antiBotActive && block.number < antiBotEndBlock) {
                                                                                                                                                                                                                                                                                                                    require(block.number >= lastBuyBlock[to] + COOLDOWN_BLOCKS, "Cooldown active");
                                                                                                                                                                                                                                                                                                                                require(value <= MAX_BUY_AMOUNT, "Exceeds max buy");
                                                                                                                                                                                                                                                                                                                                            require(balanceOf(to) + value <= MAX_WALLET_AMOUNT, "Exceeds max wallet");

                                                                                                                                                                                                                                                                                                                                                        lastBuyBlock[to] = block.number;
                                                                                                                                                                                                                                                                                                                                                                }

                                                                                                                                                                                                                                                                                                                                                                        super._update(from, to, value);
                                                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                                                            }