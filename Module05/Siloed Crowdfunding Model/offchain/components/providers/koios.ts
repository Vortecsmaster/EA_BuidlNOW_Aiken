import { PolicyId } from "@lucid-evolution/lucid";

import { req } from "../utils";

export const koios = {
  getBlockTimeMs: async () => {
    const [{ block_time }] = await req("/koios/tip?select=block_time");

    return block_time * 1_000;
  },

  getTokenMetadata: async (policyId: PolicyId) => {
    const [{ minting_tx_metadata }] = await req(
      `/koios/policy_asset_info?_asset_policy=${policyId}&select=minting_tx_metadata`,
    );

    return minting_tx_metadata["721"];
  },
};
