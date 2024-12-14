import { useWallet } from "../../contexts/wallet/WalletContext";
import { CampaignUTxO } from "../../contexts/campaign/CampaignContext";
import { finishCampaign } from "../../crowdfunding";
import ActionButton from "../base/ActionButton";

import { Platform } from "@/types/platform";

export default function ButtonFinishCampaign(props: {
  platform?: Platform;
  campaign: CampaignUTxO;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { platform, campaign, onSuccess, onError } = props;

  const [walletConnection] = useWallet();

  return (
    <ActionButton
      actionLabel="Finish Campaign"
      buttonColor="success"
      buttonVariant="shadow"
      campaignAction={() =>
        finishCampaign(walletConnection, campaign, platform)
      }
      onError={onError}
      onSuccess={onSuccess}
    />
  );
}
