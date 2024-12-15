import { createContext, Dispatch, useContext } from "react";
import {
  Address,
  Credential,
  Lovelace,
  OutRef,
  PaymentKeyHash,
  PolicyId,
  StakeKeyHash,
  Unit,
  UTxO,
  Validator,
} from "@lucid-evolution/lucid";

import { CampaignDatum, CampaignState } from "@/types/crowdfunding";

export type Support = { lovelace: Lovelace; ada: number };

export type BackerUTxO = {
  utxo: UTxO;
  pkh: PaymentKeyHash;
  skh?: StakeKeyHash;
  pk: Credential;
  sk?: Credential;
  address: Address;
  support: Support;
};

export type CampaignUTxO = {
  CampaignInfo: {
    id: PolicyId;
    platform: { pkh: PaymentKeyHash };
    nonce: OutRef;
    validator: Validator;
    address: Address;
    datum: CampaignDatum;
    data: {
      name: string;
      goal: number;
      deadline: Date;
      creator: { pk: Credential; sk?: Credential; address: Address };
      backers: BackerUTxO[];
      noDatum: UTxO[];
      support: Support;
      state: CampaignState;
    };
  };
  StateToken: {
    unit: Unit;
    utxo: UTxO;
  };
};

export type CampaignDispatchAction = {
  actionType: "Store" | "Clear";
  nextState?: CampaignUTxO;
};

export const CampaignContext = createContext<
  [CampaignUTxO | undefined, Dispatch<CampaignDispatchAction>]
>([, () => {}]);
export const useCampaign = () => useContext(CampaignContext);
