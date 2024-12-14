import { UTxO } from "@lucid-evolution/lucid";

import ActionButton from "../base/ActionButton";

import { useWallet } from "@/components/contexts/wallet/WalletContext";
import { CampaignUTxO } from "@/components/contexts/campaign/CampaignContext";
import { claimNoDatumUTXOs } from "@/components/crowdfunding";

export default function ButtonClaimNoDatumUTxO(props: {
  utxo: UTxO;
  campaign: CampaignUTxO;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { utxo, campaign, onSuccess, onError } = props;

  const [walletConnection] = useWallet();

  return (
    <ActionButton
      actionLabel="Claim"
      buttonColor="success"
      buttonVariant="flat"
      campaignAction={() => claimNoDatumUTXOs(walletConnection, campaign, utxo)}
      onError={onError}
      onSuccess={onSuccess}
    />
  );
}
