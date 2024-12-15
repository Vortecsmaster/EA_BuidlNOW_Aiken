import { useState } from "react";
import { Button } from "@nextui-org/button";
import { Input } from "@nextui-org/input";
import { Spinner } from "@nextui-org/spinner";

import { useWallet } from "../contexts/wallet/WalletContext";
import { queryCampaign } from "../crowdfunding";
import { CampaignUTxO } from "../contexts/campaign/CampaignContext";
import { handleError } from "../utils";

export default function InputCampaignId(props: {
  onSubmit?: () => void;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { onSubmit, onSuccess, onError } = props;

  const [walletConnection] = useWallet();

  const [campaignId, setCampaignId] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  async function submit() {
    const loader = document.getElementById(
      `${campaignId}-loader`,
    ) as HTMLDialogElement;

    loader.showModal();

    if (onSubmit) onSubmit();

    setIsLoading(true);
    queryCampaign(walletConnection, campaignId)
      .then(onSuccess)
      .catch((error) =>
        (onError ?? handleError)(
          "Cannot read properties of undefined (reading 'minting_tx_metadata')" ===
            error.message
            ? "Cannot find Campaign ID (the campaign might be just created, please try again later)"
            : error,
        ),
      )
      .finally(() => {
        try {
          loader.close();
        } finally {
          setIsLoading(false);
        }
      });
  }

  function ButtonGo() {
    return (
      <div className="relative">
        <Button
          className={isLoading ? "invisible" : ""}
          color={campaignId ? "primary" : "default"}
          isDisabled={!campaignId}
          size="sm"
          variant="ghost"
          onPress={submit}
        >
          Go
        </Button>
        {isLoading && (
          <Spinner className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        )}
      </div>
    );
  }

  return (
    <>
      <Input
        className="w-96"
        endContent={<ButtonGo />}
        label="Enter Campaign ID"
        radius="sm"
        variant="bordered"
        onKeyDown={(e) => {
          if (campaignId && !isLoading && e.code.endsWith("Enter")) submit();
        }}
        onValueChange={setCampaignId}
      />
      <dialog id={`${campaignId}-loader`} />
    </>
  );
}
