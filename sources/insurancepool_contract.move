module addr::InsurancePool {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

    /// Struct representing an insurance pool with mutual coverage
    struct Pool has store, key {
        total_funds: u64,           // Total premiums collected
        members: vector<address>,   // List of pool members
        premium_amount: u64,        // Required premium to join
        active_claims: u64,         // Number of pending claims
    }

    /// Struct representing a claim made by a member
    struct Claim has store, key {
        amount: u64,        // Claim amount requested
        is_approved: bool,  // Claim approval status
        votes_for: u64,     // Votes in favor of the claim
        votes_against: u64, // Votes against the claim
        total_voters: u64,  // Total number of voters
    }

    /// Function to create a new insurance pool with specified premium
    public fun create_pool(owner: &signer, premium_amount: u64) {
        let pool = Pool {
            total_funds: 0,
            members: vector::empty<address>(),
            premium_amount,
            active_claims: 0,
        };
        move_to(owner, pool);
    }

    /// Function for users to join the pool by paying premium
    public fun join_pool(member: &signer, pool_owner: address) acquires Pool {
        let pool = borrow_global_mut<Pool>(pool_owner);
        let member_addr = signer::address_of(member);
        
        // Transfer premium from member to pool owner
        let premium = coin::withdraw<AptosCoin>(member, pool.premium_amount);
        coin::deposit<AptosCoin>(pool_owner, premium);
        
        // Add member to pool and update total funds
        vector::push_back(&mut pool.members, member_addr);
        pool.total_funds = pool.total_funds + pool.premium_amount;
    }

    /// Function to submit and assess a claim (simplified voting mechanism)
    public fun submit_claim(claimant: &signer, amount: u64, votes_for: u64, total_voters: u64) {
        let is_approved = votes_for > (total_voters / 2); // Simple majority vote
        
        let claim = Claim {
            amount,
            is_approved,
            votes_for,
            votes_against: total_voters - votes_for,
            total_voters,
        };
        move_to(claimant, claim);
    }
}