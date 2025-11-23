// types.nr courtesy of zkpassport team!

use dep::aztec::protocol_types::traits::{Deserialize, Serialize};
// Should change this to below? but tests passed lol
// global VKEY_SIZE: u32 = 115;
// global PROOF_SIZE: u32 = 508;

//compressed evm, 456

pub global VKEY_SIZE: u32 = 115;
pub global PROOF_SIZE: u32 = 508;
pub global PUBLIC_INPUT_A_SIZE: u32 = 2;
pub global PUBLIC_INPUT_B_SIZE: u32 = 2;
pub global PUBLIC_INPUT_C_SIZE: u32 = 3;
pub global PUBLIC_INPUT_D_SIZE: u32 = 5;
pub global HONK_IDENTIFIER: u32 = 7;
pub global KEY_HASH: Field = 0;
pub global PUBLIC_INPUT_SIZE: u32 = 7;
pub global VKEY_HASH_SIZE: u32 = 1;

pub struct ProofInputs {
    pub vkey: [Field; VKEY_SIZE],
    pub vkey_hash: Field,
    pub proof: [Field; PROOF_SIZE],
    pub public_inputs: [Field; PUBLIC_INPUT_SIZE],
}

impl Serialize for ProofInputs {
    let N: u32 = VKEY_SIZE + VKEY_HASH_SIZE + PROOF_SIZE + PUBLIC_INPUT_SIZE;

    fn serialize(self) -> [Field; Self::N] {
        let mut result: [Field; Self::N] = [0; Self::N];
        let mut offset = 0;

        // Serialize vkey (115 fields)
        for i in 0..VKEY_SIZE {
            result[offset + i] = self.vkey[i];
        }
        offset += VKEY_SIZE;

        // Serialize vkey_hash (1 field)
        result[offset] = self.vkey_hash;
        offset += VKEY_HASH_SIZE;

        // Serialize proof (508 fields)
        for i in 0..PROOF_SIZE {
            result[offset + i] = self.proof[i];
        }
        offset += PROOF_SIZE;

        // Serialize public_inputs (7 fields)
        for i in 0..PUBLIC_INPUT_SIZE {
            result[offset + i] = self.public_inputs[i];
        }

        result
    }
}

impl Deserialize for ProofInputs {
    let N: u32 = VKEY_SIZE + VKEY_HASH_SIZE + PROOF_SIZE + PUBLIC_INPUT_SIZE;

    fn deserialize(fields: [Field; Self::N]) -> Self {
        let mut offset = 0;

        // Deserialize vkey (115 fields)
        let mut vkey: [Field; VKEY_SIZE] = [0; VKEY_SIZE];
        for i in 0..VKEY_SIZE {
            vkey[i] = fields[offset + i];
        }
        offset += VKEY_SIZE;

        // Deserialize vkey_hash (1 field)
        let vkey_hash = fields[offset];
        offset += VKEY_HASH_SIZE;

        // Deserialize proof (508 fields)
        let mut proof: [Field; PROOF_SIZE] = [0; PROOF_SIZE];
        for i in 0..PROOF_SIZE {
            proof[i] = fields[offset + i];
        }
        offset += PROOF_SIZE;

        // Deserialize public_inputs (7 fields)
        let mut public_inputs: [Field; PUBLIC_INPUT_SIZE] = [0; PUBLIC_INPUT_SIZE];
        for i in 0..PUBLIC_INPUT_SIZE {
            public_inputs[i] = fields[offset + i];
        }

        ProofInputs { vkey, vkey_hash, proof, public_inputs }
    }
}
