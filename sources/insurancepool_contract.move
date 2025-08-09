module addr::InsurancePool {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

  
    struct Pool has store, key {
        total_funds: u64,         
        members: vector<address>,   
        premium_amount: u64,       
        active_claims: u64,         
    }

   
    struct Claim has store, key {
        amount: u64,       
        is_approved: bool,  
        votes_for: u64,     
        votes_against: u64, 
        total_voters: u64, 
    }

   
    public fun create_pool(owner: &signer, premium_amount: u64) {
        let pool = Pool {
            total_funds: 0,
            members: vector::empty<address>(),
            premium_amount,
            active_claims: 0,
        };
        move_to(owner, pool);
    }

   
    public fun join_pool(member: &signer, pool_owner: address) acquires Pool {
        let pool = borrow_global_mut<Pool>(pool_owner);
        let member_addr = signer::address_of(member);
        
       
        let premium = coin::withdraw<AptosCoin>(member, pool.premium_amount);
        coin::deposit<AptosCoin>(pool_owner, premium);
        
       
        vector::push_back(&mut pool.members, member_addr);
        pool.total_funds = pool.total_funds + pool.premium_amount;
    }

   
    public fun submit_claim(claimant: &signer, amount: u64, votes_for: u64, total_voters: u64) {
        let is_approved = votes_for > (total_voters / 2); 
        
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
