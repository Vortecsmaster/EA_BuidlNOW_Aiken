import ActionButton from "../base/ActionButton";

import { useWallet } from "@/components/contexts/wallet/WalletContext";
import { CampaignUTxO } from "@/components/contexts/campaign/CampaignContext";
import { claimNoDatumUTXOs } from "@/components/crowdfunding";

export default function ButtonClaimAllNoDatumUTXOs(props: {
  campaign: CampaignUTxO;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { campaign, onSuccess, onError } = props;

  const [walletConnection] = useWallet();

  return (
    <ActionButton
      actionLabel="Claim All"
      buttonColor="success"
      buttonVariant="shadow"
      campaignAction={() => claimNoDatumUTXOs(walletConnection, campaign)}
      onError={onError}
      onSuccess={onSuccess}
    />
  );
}
