#[starknet::contract]
pub mod beast_token {
    use starknet::{ContractAddress, get_caller_address};
    use openzeppelin::token::erc20::ERC20;
    use openzeppelin::access::ownable::Ownable;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20::Storage,
        #[substorage(v0)]
        ownable: Ownable::Storage,
        // Mapping to track which contracts are authorized to mint tokens
        authorized_minters: LegacyMap<ContractAddress, bool>,
        // Token rewards configuration
        attack_reward_amount: u256,
        level_up_reward_amount: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20::Event,
        #[flat]
        OwnableEvent: Ownable::Event,
        RewardMinted: RewardMinted,
    }

    #[derive(Drop, starknet::Event)]
    struct RewardMinted {
        player: ContractAddress,
        amount: u256,
        reason: felt252,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        initial_supply: u256,
        recipient: ContractAddress,
        owner: ContractAddress,
        attack_reward: u256,
        level_up_reward: u256
    ) {
        // Initialize ERC20
        self.erc20.initializer(name, symbol);
        
        // Mint initial supply to recipient
        self.erc20._mint(recipient, initial_supply);
        
        // Set contract owner
        self.ownable.initializer(owner);
        
        // Set reward amounts
        self.attack_reward_amount.write(attack_reward);
        self.level_up_reward_amount.write(level_up_reward);
    }

    #[external(v0)]
    fn authorize_minter(ref self: ContractState, minter: ContractAddress) {
        // Only owner can authorize minters
        self.ownable.assert_only_owner();
        self.authorized_minters.write(minter, true);
    }

    #[external(v0)]
    fn revoke_minter(ref self: ContractState, minter: ContractAddress) {
        // Only owner can revoke minters
        self.ownable.assert_only_owner();
        self.authorized_minters.write(minter, false);
    }

    #[external(v0)]
    fn set_attack_reward(ref self: ContractState, amount: u256) {
        // Only owner can change reward amounts
        self.ownable.assert_only_owner();
        self.attack_reward_amount.write(amount);
    }

    #[external(v0)]
    fn set_level_up_reward(ref self: ContractState, amount: u256) {
        // Only owner can change reward amounts
        self.ownable.assert_only_owner();
        self.level_up_reward_amount.write(amount);
    }

    #[external(v0)]
    fn mint_attack_reward(ref self: ContractState, player: ContractAddress) {
        // Only authorized minters can call this function
        let caller = get_caller_address();
        assert(self.authorized_minters.read(caller), 'Not authorized to mint');
        
        // Get the reward amount
        let amount = self.attack_reward_amount.read();
        
        // Mint tokens to the player
        self.erc20._mint(player, amount);
        
        // Emit event
        self.emit(RewardMinted { player, amount, reason: 'attack' });
    }

    #[external(v0)]
    fn mint_level_up_reward(ref self: ContractState, player: ContractAddress) {
        // Only authorized minters can call this function
        let caller = get_caller_address();
        assert(self.authorized_minters.read(caller), 'Not authorized to mint');
        
        // Get the reward amount
        let amount = self.level_up_reward_amount.read();
        
        // Mint tokens to the player
        self.erc20._mint(player, amount);
        
        // Emit event
        self.emit(RewardMinted { player, amount, reason: 'level_up' });
    }

    // Implement ERC20 interface
    #[external(v0)]
    fn name(self: @ContractState) -> felt252 {
        self.erc20.name()
    }

    #[external(v0)]
    fn symbol(self: @ContractState) -> felt252 {
        self.erc20.symbol()
    }

    #[external(v0)]
    fn decimals(self: @ContractState) -> u8 {
        self.erc20.decimals()
    }

    #[external(v0)]
    fn total_supply(self: @ContractState) -> u256 {
        self.erc20.total_supply()
    }

    #[external(v0)]
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
        self.erc20.balance_of(account)
    }

    #[external(v0)]
    fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
        self.erc20.allowance(owner, spender)
    }

    #[external(v0)]
    fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
        self.erc20.transfer(recipient, amount)
    }

    #[external(v0)]
    fn transfer_from(
        ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool {
        self.erc20.transfer_from(sender, recipient, amount)
    }

    #[external(v0)]
    fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
        self.erc20.approve(spender, amount)
    }

    // Ownable interface
    #[external(v0)]
    fn owner(self: @ContractState) -> ContractAddress {
        self.ownable.owner()
    }

    #[external(v0)]
    fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
        self.ownable.transfer_ownership(new_owner);
    }

    #[external(v0)]
    fn renounce_ownership(ref self: ContractState) {
        self.ownable.renounce_ownership();
    }
} 