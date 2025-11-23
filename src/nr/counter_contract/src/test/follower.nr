use crate::{Counter, test::utils, types::ProofInputs};
use aztec::protocol_types::address::AztecAddress;
use aztec::protocol_types::traits::FromField;

#[test]
unconstrained fn test_get_owner() {
    let (mut env, contract_address, owner, _) = utils::setup_contract(false);

    let retrieved_owner = env.call_public(owner, Counter::at(contract_address).get_owner());
    assert(retrieved_owner == owner);
}

#[test]
unconstrained fn test_add_follower_note_nocheck() {
    let (mut env, contract_address, owner, _) = utils::setup_contract(false);

    let nostr_pubkey = AztecAddress::from_field(12345);

    // Test that we can call the function without errors
    env.call_private(
        owner,
        Counter::at(contract_address).add_follower_note_nocheck(nostr_pubkey, owner),
    );

    // Note: Utility/view functions need to be tested through integration tests
    // as they require special handling in Noir test environment
}

#[test]
unconstrained fn test_add_follower_note_with_proof() {
    let (mut env, contract_address, owner, _) = utils::setup_contract(false);

    let nostr_pubkey = AztecAddress::from_field(67890);
    let zk_id = 42;

    // Create a dummy ProofInputs structure
    // Note: The proof verification is commented out in the contract, so we can use dummy values
    let mut public_inputs: [Field; 7] = [0; 7];
    public_inputs[6] = zk_id; // Set the zk_id at index 6 as expected by the contract

    let proof_inputs = ProofInputs { vkey: [0; 115], vkey_hash: 0, proof: [0; 508], public_inputs };

    // Test that we can call the function without errors
    env.call_private(
        owner,
        Counter::at(contract_address).add_follower_note(proof_inputs, zk_id, nostr_pubkey, owner),
    );

    // Note: Utility/view functions need to be tested through integration tests
}

#[test]
unconstrained fn test_multiple_follower_notes() {
    let (mut env, contract_address, owner, _) = utils::setup_contract(false);

    let nostr_pubkey1 = AztecAddress::from_field(11111);
    let nostr_pubkey2 = AztecAddress::from_field(22222);

    // Test adding multiple notes
    env.call_private(
        owner,
        Counter::at(contract_address).add_follower_note_nocheck(nostr_pubkey1, owner),
    );
    env.call_private(
        owner,
        Counter::at(contract_address).add_follower_note_nocheck(nostr_pubkey2, owner),
    );

    // Note: Verification of notes should be done through integration tests
}

#[test]
unconstrained fn test_different_owners() {
    let (mut env, contract_address, owner, user) = utils::setup_contract(false);

    let nostr_pubkey1 = AztecAddress::from_field(44444);
    let nostr_pubkey2 = AztecAddress::from_field(55555);

    // Test that different owners can add notes
    env.call_private(
        owner,
        Counter::at(contract_address).add_follower_note_nocheck(nostr_pubkey1, owner),
    );
    env.call_private(
        user,
        Counter::at(contract_address).add_follower_note_nocheck(nostr_pubkey2, user),
    );

    // Note: Verification of note isolation should be done through integration tests
}

#[test]
unconstrained fn test_initializer_sets_owner() {
    let mut env = aztec::test::helpers::test_environment::TestEnvironment::new();

    let owner = env.create_light_account();

    let initializer_call_interface = Counter::interface().constructor(owner);
    let counter_deployer = env.deploy("@counter_contract/Counter");
    let contract_address =
        counter_deployer.with_public_initializer(owner, initializer_call_interface);

    let retrieved_owner = env.call_public(owner, Counter::at(contract_address).get_owner());
    assert(retrieved_owner == owner);
}
