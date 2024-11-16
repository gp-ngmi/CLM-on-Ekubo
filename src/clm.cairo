#[starknet::contract]
pub mod ConcentratedLiquidityManager {
    
    // Core lib imports.
    use starknet::ContractAddress;
    use starknet::{
        get_caller_address, get_contract_address, get_block_number, get_block_timestamp
    };

    // Local imports.
    use clm_ekubo::interface::IConcentradedLiquidityManager;

    // External imports.
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

    // Ekubo imports
    use ekubo::interfaces::positions::{GetTokenInfoResult, GetTokenInfoRequest, IPositions};

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
        pool_manager: IMarketManagerDispatcher,
        // NFT ID
        position_id: GetTokenInfoRequest,
        // NFT
        position_info: GetTokenInfoResult,
        // user share on the manager
        balance_of: Map<ContractAddress, u256>,
        // total supply of of the manager
        total_supply: u256,
    }
}