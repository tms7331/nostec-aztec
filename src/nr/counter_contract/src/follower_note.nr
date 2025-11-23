use aztec::{
    macros::notes::note,
    oracle::random::random,
    protocol_types::{address::AztecAddress, traits::{Deserialize, Packable, Serialize}},
};

#[derive(Eq, Serialize, Deserialize, Packable)]
#[note]
pub struct FollowerNote {
    randomness: Field,
    nostr_pubkey: AztecAddress,
    owner: AztecAddress,
}

impl FollowerNote {
    pub fn new(nostr_pubkey: AztecAddress, owner: AztecAddress) -> Self {
        // Safety: We use the randomness to preserve the privacy of the note recipient by preventing brute-forcing,
        // so a malicious sender could use non-random values to make the note less private. But they already know
        // the full note pre-image anyway, and so the recipient already trusts them to not disclose this
        // information. We can therefore assume that the sender will cooperate in the random value generation.
        let randomness = unsafe { random() };

        Self { randomness, nostr_pubkey, owner }
    }

    pub fn get_nostr_pubkey(self) -> AztecAddress {
        self.nostr_pubkey
    }
    pub fn get_owner(self) -> AztecAddress {
        self.owner
    }
}
