"use client";

import { useReducer } from "react";

import {
  CampaignContext,
  CampaignDispatchAction,
  CampaignUTxO,
} from "./CampaignContext";

export default function CampaignProvider(props: { children: React.ReactNode }) {
  return (
    <CampaignContext.Provider
      value={useReducer(
        (
          currState: CampaignUTxO | undefined,
          { actionType, nextState }: CampaignDispatchAction,
        ) => {
          switch (actionType) {
            case "Store":
              return nextState;

            case "Clear":
              return undefined;

            default:
              return currState;
          }
        },
        undefined,
      )}
    >
      {props.children}
    </CampaignContext.Provider>
  );
}
