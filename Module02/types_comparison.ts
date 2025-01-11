aiken
    pub type CFdatum {
        goal: Int,
        backer: VerificationKeyHash,
        deadline: Int,
   }

aiken Bool
    False    
    True

aiken AuctionDatum {
    price: Int,
    seller: VerificationKeyHash,
    deadline: Int,
}

aiken Option<Int>
   Some(Int)
   None

Cardano-API (ScriptData -> JSON)

{"constructor":0,"fields":[{"int": 1000000000},{"bytes": "697a501b7d05766b3d08e39dab43e0f170973d3398b28745b3b8ce55"},{"int": 1733677200000 }]}

{"constructor":0,"fields":[]}
{"constructor":1,"fields":[]}


Lucid Data (Typescript)

const datum = Data.to(new Constr(0, [1000000000n,
        "697a501b7d05766b3d08e39dab43e0f170973d3398b28745b3b8",
        1733677200000n]));