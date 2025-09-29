// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title RelicsAirdropBatch (RAB)
/// @notice Token + Airdrop Vesting + Batch Release
contract RelicsAirdropBatch {
    /*//////////////////////////////////////////////////////////////
                                ERC20
    //////////////////////////////////////////////////////////////*/
    string public constant name = "RelicsAirdropBatch";
    string public constant symbol = "RAB";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 5_000_000 * 1e18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                                VESTING
    //////////////////////////////////////////////////////////////*/
    struct Vesting {
        uint256 remainingAmount;
        uint256 trancheInterval;
        uint256 trancheAmount;
        uint256 nextReleaseTime;
        bool active;
    }

    mapping(address => Vesting) public vestings;
    address public immutable owner;
    address[] public participants;

    uint256 public constant TOTAL_PER_USER = 25_000 * 1e18;
    uint256 public constant INITIAL_AMOUNT = 10_000 * 1e18;
    uint256 public constant TRANCHE_AMOUNT = 5_000 * 1e18;
    uint256 public constant TRANCHE_INTERVAL = 3600; // 1 jam
    uint256 public constant FEE_PERCENT = 5;

    event VestingCreated(address indexed user);
    event TranchePaid(address indexed user, uint256 netAmount, uint256 fee, uint256 remaining);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    /// @notice User klaim sekali, langsung dapet initial
    function claim() external {
        require(!vestings[msg.sender].active, "Already claimed");
        require(balanceOf[owner] >= TOTAL_PER_USER, "Not enough supply");

        vestings[msg.sender] = Vesting({
            remainingAmount: TOTAL_PER_USER - INITIAL_AMOUNT,
            trancheInterval: TRANCHE_INTERVAL,
            trancheAmount: TRANCHE_AMOUNT,
            nextReleaseTime: block.timestamp + TRANCHE_INTERVAL,
            active: true
        });

        participants.push(msg.sender);

        // kirim initial
        uint256 fee = (INITIAL_AMOUNT * FEE_PERCENT) / 100;
        uint256 net = INITIAL_AMOUNT - fee;

        _transfer(owner, owner, fee);
        _transfer(owner, msg.sender, net);

        emit VestingCreated(msg.sender);
        emit TranchePaid(msg.sender, net, fee, TOTAL_PER_USER - INITIAL_AMOUNT);
    }

    /// @notice Owner transfer batch sekali klik
    function transferBatch() external onlyOwner {
        for (uint256 i = 0; i < participants.length; i++) {
            _processUser(participants[i]);
        }
    }

    function _processUser(address user) internal {
        Vesting storage v = vestings[user];

        while (v.active && block.timestamp >= v.nextReleaseTime) {
            uint256 toPay = v.trancheAmount;
            if (toPay > v.remainingAmount) {
                toPay = v.remainingAmount;
            }

            uint256 fee = (toPay * FEE_PERCENT) / 100;
            uint256 net = toPay - fee;

            _transfer(owner, owner, fee);
            _transfer(owner, user, net);

            v.remainingAmount -= toPay;

            if (v.remainingAmount == 0) {
                v.active = false;
                v.nextReleaseTime = 0;
            } else {
                v.nextReleaseTime += v.trancheInterval;
            }

            emit TranchePaid(user, net, fee, v.remainingAmount);
        }
    }
}
