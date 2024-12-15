import { useWallet } from "../../contexts/wallet/WalletContext";
import { CampaignUTxO } from "../../contexts/campaign/CampaignContext";
import { cancelCampaign } from "../../crowdfunding";
import ActionButton from "../base/ActionButton";

import { Platform } from "@/types/platform";

export default function ButtonCancelCampaign(props: {
  platform?: Platform;
  campaign: CampaignUTxO;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { platform, campaign, onSuccess, onError } = props;

  const [walletConnection] = useWallet();

  return (
    <ActionButton
      actionLabel="Cancel Campaign"
      buttonColor="danger"
      buttonVariant="flat"
      campaignAction={() =>
        cancelCampaign(walletConnection, campaign, platform)
      }
      onError={onError}
      onSuccess={onSuccess}
    />
  );
}
