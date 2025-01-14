import { useWallet } from "../../contexts/wallet/WalletContext";
import { CampaignUTxO } from "../../contexts/campaign/CampaignContext";
import { refundCampaign } from "../../crowdfunding";
import ActionButton from "../base/ActionButton";

import { Platform } from "@/types/platform";

export default function ButtonRefundCampaign(props: {
  platform?: Platform;
  campaign: CampaignUTxO;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { platform, campaign, onSuccess, onError } = props;

  const [walletConnection] = useWallet();

  return (
    <ActionButton
      actionLabel="Refund Campaign"
      buttonColor="warning"
      buttonVariant="flat"
      campaignAction={() =>
        refundCampaign(walletConnection, campaign, platform)
      }
      onError={onError}
      onSuccess={onSuccess}
    />
  );
}
