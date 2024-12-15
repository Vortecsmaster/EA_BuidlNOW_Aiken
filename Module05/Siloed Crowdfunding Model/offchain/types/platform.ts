import {
  Address,
  PaymentKeyHash,
  RewardAddress,
  StakeKeyHash,
} from "@lucid-evolution/lucid";

export type Platform = {
  address: Address;
  pkh: PaymentKeyHash;
  stakeAddress: RewardAddress;
  skh: StakeKeyHash;
};
