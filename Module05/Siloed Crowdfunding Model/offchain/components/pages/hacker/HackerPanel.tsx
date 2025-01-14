import { useState } from "react";
import { Divider } from "@nextui-org/divider";
import { Skeleton } from "@nextui-org/skeleton";

import HackNoDatumUTxO from "./HackNoDatumUTxO";

import { handleError } from "@/components/utils";
import { CampaignUTxO } from "@/components/contexts/campaign/CampaignContext";
import InputCampaignId from "@/components/campaign/InputCampaignId";
import CampaignCard from "@/components/campaign/CampaignCard";
import ButtonHackCancelCampaign from "@/components/buttons/hacker/ButtonHackCancelCampaign";
import ButtonHackFinishCampaign from "@/components/buttons/hacker/ButtonHackFinishCampaign";
import ButtonHackRefundCampaign from "@/components/buttons/hacker/ButtonHackRefundCampaign";
import ButtonHackRerunCampaign from "@/components/buttons/hacker/ButtonHackRerunCampaign";
import ButtonHackClaimAllNoDatumUTXOs from "@/components/buttons/hacker/ButtonHackClaimAllNoDatumUTXOs";

export default function HackerPanel() {
  const [campaign, setCampaign] = useState<CampaignUTxO>();
  const [isQueryingCampaign, setIsQueryingCampaign] = useState(false);

  return (
    <div className="flex flex-col items-center gap-3">
      {/* Input Campaign ID */}
      <InputCampaignId
        onError={handleError}
        onSubmit={() => setIsQueryingCampaign(true)}
        onSuccess={(campaign) => {
          setCampaign(campaign);
          setIsQueryingCampaign(false);
        }}
      />

      {/* Campaign Card + NoDatum UTxOs */}
      {campaign && (
        <div className="flex flex-col gap-4 w-fit">
          {/* Campaign Card */}
          <Skeleton className="rounded-lg w-fit" isLoaded={!isQueryingCampaign}>
            <CampaignCard
              actionButtons={
                campaign.CampaignInfo.data.state === "Running" ? (
                  <div className="flex gap-3">
                    <ButtonHackCancelCampaign
                      campaign={campaign}
                      onError={handleError}
                      onSuccess={setCampaign}
                    />
                    <ButtonHackFinishCampaign
                      campaign={campaign}
                      onError={handleError}
                      onSuccess={setCampaign}
                    />
                  </div>
                ) : (
                  <div className="flex gap-3">
                    <ButtonHackRefundCampaign
                      campaign={campaign}
                      onError={handleError}
                      onSuccess={setCampaign}
                    />
                    <ButtonHackRerunCampaign
                      campaign={campaign}
                      onError={handleError}
                      onSuccess={setCampaign}
                    />
                  </div>
                )
              }
              campaign={campaign}
              hasActions={true}
            />
          </Skeleton>

          {/* NoDatum UTxOs */}
          {campaign.CampaignInfo.data.noDatum.length > 0 && (
            <>
              <Divider />
              <div className="flex justify-between w-full px-3">
                {/* NoDatum UTxOs Label */}
                <Skeleton
                  className="rounded-lg w-fit my-auto"
                  isLoaded={!isQueryingCampaign}
                >
                  <span className="font-bold">NoDatum UTxOs</span>
                </Skeleton>

                {/* Claim All Button */}
                {campaign.CampaignInfo.data.noDatum.length > 1 && (
                  <Skeleton
                    className="rounded-lg w-fit"
                    isLoaded={!isQueryingCampaign}
                  >
                    <ButtonHackClaimAllNoDatumUTXOs
                      campaign={campaign}
                      onError={handleError}
                      onSuccess={setCampaign}
                    />
                  </Skeleton>
                )}
              </div>
              <Divider />
            </>
          )}
          {campaign.CampaignInfo.data.noDatum.map((utxo) => (
            <Skeleton
              key={`${utxo.txHash}#${utxo.outputIndex}`}
              className="rounded-lg w-full"
              isLoaded={!isQueryingCampaign}
            >
              <HackNoDatumUTxO
                campaign={campaign}
                utxo={utxo}
                onError={handleError}
                onSuccess={setCampaign}
              />
            </Skeleton>
          ))}
        </div>
      )}
    </div>
  );
}
