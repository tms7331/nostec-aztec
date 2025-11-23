use aztec::macros::aztec;
pub mod test;
mod follower_note;
mod types;

#[aztec]
pub contract Counter {
    // aztec library imports
    use crate::follower_note::FollowerNote;
    use crate::types::{HONK_IDENTIFIER, ProofInputs};
    use aztec::{
        macros::{functions::{external, initializer, internal, view}, storage::storage},
        protocol_types::{address::AztecAddress, traits::FromField},
        state_vars::{Map, PrivateSet, PublicImmutable, PublicMutable},
    };
    use aztec::messages::message_delivery::MessageDelivery;
    use aztec::note::constants::MAX_NOTES_PER_PAGE;
    use aztec::note::note_viewer_options::NoteViewerOptions;
    use std::verify_proof_with_type;

    // @param owner The address of the owner
    // @param follower_notes A private set of follower notes
    #[storage]
    struct Storage<Context> {
        owner: PublicImmutable<AztecAddress, Context>,
        follower_notes: Map<AztecAddress, PrivateSet<FollowerNote, Context>, Context>,
    }

    /// @dev Initialize the contract
    /// @param owner The address of the owner
    #[external("public")]
    #[initializer]
    fn constructor(owner: AztecAddress) {
        storage.owner.initialize(owner);
    }

    /// @dev Retrieves the owner of the contract
    /// @return The owner of the contract
    #[external("public")]
    fn get_owner() -> AztecAddress {
        storage.owner.read()
    }

    #[external("private")]
    fn add_follower_note_nocheck(nostr_pubkey: AztecAddress, owner: AztecAddress) {
        // let sender = context.msg_sender().unwrap();
        let note = FollowerNote::new(nostr_pubkey, owner);
        storage.follower_notes.at(owner).insert(note).emit(
            owner,
            MessageDelivery.UNCONSTRAINED_ONCHAIN,
        );
    }

    #[external("private")]
    fn add_follower_note(
        circuitInputs: ProofInputs,
        zk_id: Field,
        nostr_pubkey: AztecAddress,
        owner: AztecAddress,
    ) {
        assert(
            circuitInputs.public_inputs[6] == zk_id,
            "scoped nullifier of proof_d does not match zk_id",
        );

        // // Verify all proofs
        // verify_proof_with_type(
        //     circuitInputs.vkey,
        //     circuitInputs.proof,
        //     circuitInputs.public_inputs,
        //     circuitInputs.vkey_hash,
        //     HONK_IDENTIFIER,
        // );
        let note = FollowerNote::new(nostr_pubkey, owner);
        storage.follower_notes.at(owner).insert(note).emit(
            owner,
            MessageDelivery.UNCONSTRAINED_ONCHAIN,
        );
    }

    #[external("utility")]
    unconstrained fn get_nostr_pubkeys(
        owner: AztecAddress,
    ) -> pub [AztecAddress; MAX_NOTES_PER_PAGE] {
        let notes = storage.follower_notes.at(owner).view_notes(NoteViewerOptions::new());
        let notes_array: [FollowerNote; MAX_NOTES_PER_PAGE] = notes.storage();
        let mut addresses: [AztecAddress; MAX_NOTES_PER_PAGE] =
            [AztecAddress::from_field(0); MAX_NOTES_PER_PAGE];
        let mut index = 0;
        for note in notes_array {
            if index < MAX_NOTES_PER_PAGE {
                addresses[index] = note.get_nostr_pubkey();
                index = index + 1;
            }
        }
        addresses
    }

    #[external("utility")]
    unconstrained fn view_follower_notes(
        owner: AztecAddress,
    ) -> [FollowerNote; MAX_NOTES_PER_PAGE] {
        let notes = storage.follower_notes.at(owner).view_notes(NoteViewerOptions::new());
        notes.storage()
    }

}
