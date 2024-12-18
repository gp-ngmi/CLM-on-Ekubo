#[starknet::contract]
pub mod TemplateConcentratedLiquidityManager {
    
    // Core lib imports.
    use starknet::ContractAddress;
    use starknet::{
        get_caller_address, get_contract_address, get_block_number, get_block_timestamp
    };
    use integer::BoundedU256;

    // Local imports.
    use clm_ekubo::interface::IConcentradedLiquidityManager;

    // External imports.
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

    // Ekubo imports
    use ekubo::interfaces::positions::{GetTokenInfoResult, GetTokenInfoRequest, IPositions, Bounds};

    ////////////////////////////////
    // STORAGE
    ///////////////////////////////

    #[storage]
    struct Storage {
        // Manager name
        name: felt252,
        // Manager symbol
        symbol: felt252,
        // pool manager
        pool_manager: IPositions,
        // NFT ID
        position_id: GetTokenInfoRequest,
        // NFT
        position_info: GetTokenInfoResult,
        // user share on the manager
        balance_of: Map<ContractAddress, u256>,
        // total supply of of the manager
        total_supply: u256,
        // liquidity of the manager
        liquidity: u256,
        // token0
        token0: IERC20Dispatcher,
        //token1
        token1: IERC20Dispatcher,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, 
        token0: ContractAddress, 
        token1: ContractAddress, 
        name: felt252, 
        symbol: felt252, 
        pool_manager: ContractAddress,  
        id: u64, 
        pool_key: PoolKey, 
        bounds: Bounds
    ) {
        let token0_dispatcher = IERC20Dispatcher { contract_address: token0 };
        self.token0.write(token0_dispatcher);
        token0_dispatcher.approve(pool_manager, BoundedU256::max());

        let token1_dispatcher = IERC20Dispatcher { contract_address: token1 };
        self.token1.write(token1_dispatcher);
        token1_dispatcher.approve(pool_manager, BoundedU256::max())

        self.name.write(name);
        self.symbol.write(symbol);

        let pool_manager_dispatcher = IPositions { contract_address: pool_manager };
        self.pool_manager.write(pool_manager_dispatcher);

        let position_id = GetTokenInfoRequest {id: id, pool_key:pool_key,bounds:bounds};
        self.position_id.write(position_id);


    }

    #[abi(embed_v0)]
    impl ConcentradedLiquidityManager of IConcentradedLiquidityManager<ContractState> {
        
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }


       fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balance_of.read(account)
        }

        fn harvest(self: @ContractState) -> u256 {

            // Withdraw liquidity
            let position_id = self.position_id.read();
            let liquidity = self.liquidity.read();

            self.pool_manager.withdraw_v2(position_id.id, position_id.pool_key, position_id.bounds, liquidity, 0, 0)
            self.pool_manager.collect_fees(position_id.id, position_id.pool_key, position_id.bounds);
        
            // Swap in order to have 50/50

            // Update bounds

            // Compute liquidity

            // Deposit liquidity
            self.pool_manager.mint_and_deposit(position_id.pool_key, position_id.bounds, liquidity);

            return liquidity;
        }

        fn deposit(self: @ContractState,  min_liquidity: u128, receiver: ContractAddress) -> (u256, u256) {

            // Compute token0 and token1 based on min_liquidity
            let token0_amount = 0;
            let token1_amount = 0;

            // transfer token0 and token1 to the manager
            let caller = get_caller_address();
            self.token0.transfer_from(caller, get_contract_address(), token0_amount);
            self.token1.transfer_from(caller, get_contract_address(), token1_amount);

            // Mint shares
            let total_supply = self.total_supply.read();
            self.total_supply.write(total_supply + min_liquidity);
            self.balance_of.write(receiver, min_liquidity);
            self.liquidity.write(min_liquidity);

            // Deposit liquidity
            self.harvest();

            return token0_amount, token1_amount;
        }

        fn withdraw_all(self: @ContractState,  shares: u128, receiver: ContractAddress) -> (u256, u256) {

            // Withdraw liquidity
            let position_id = self.position_id.read();
            let liquidity = self.liquidity.read();

            self.pool_manager.withdraw_v2(position_id.id, position_id.pool_key, position_id.bounds, liquidity, 0, 0)
            self.pool_manager.collect_fees(position_id.id, position_id.pool_key, position_id.bounds);
        
            // Compute token0 and token1 based on shares and liquidity
            let token0_amount = 0;
            let token1_amount = 0;

            // burn shares
            let caller = get_caller_address();
            let user_shares =  self.balance_of.read(caller);
            self.balance_of.write(caller, user_shares - shares);
            self.total_supply.write(total_supply - shares);
            
            // Send tokens
            self.token0.transfer(receiver, token0_amount);
            self.token1.transfer(receiver, token1_amount);

            // Swap in order to have 50/50

            // Update bounds

            // Compute liquidity

            // Deposit liquidity
            self.pool_manager.mint_and_deposit(position_id.pool_key, position_id.bounds, liquidity);

            return token0_amount, token1_amount;
        }
    }
}