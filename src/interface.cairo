// Core lib imports.
use starknet::ContractAddress;

// Interface of the CLM contract.
#[starknet::interface]
pub trait IConcentradedLiquidityManager<TContractState> {


    ////////////////////////////////
    // Metadata
    ///////////////////////////////

    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;

    ////////////////////////////////
    // Shares
    ///////////////////////////////
 
    fn total_supply(self: @TState) -> u256;
    fn balance_of(self: @TState, account: ContractAddress) -> u256;

    ////////////////////////////////
    // Entry points
    ///////////////////////////////

    // Deposit liquidity
    fn deposit(
        ref self: TContractState, min_liquidity: u128, receiver: starknet::ContractAddress
    ) -> (u256, u256);
    
    // Burn pool shares and withdraw funds
    fn withdraw_all(ref self: TContractState, shares: u256, receiver: starknet::ContractAddress) -> (u256, u256);

    // Harvest fees and rebalance the positionn
    fn harvest(ref self: TContractState) -> (u256);

}