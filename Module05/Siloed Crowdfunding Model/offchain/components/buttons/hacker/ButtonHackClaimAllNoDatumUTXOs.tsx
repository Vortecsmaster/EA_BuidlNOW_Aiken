import { useEffect, useState } from "react";
import { Button } from "@nextui-org/button";
import { Checkbox } from "@nextui-org/checkbox";
import { Input } from "@nextui-org/input";
import {
  Modal,
  ModalBody,
  ModalContent,
  ModalFooter,
  ModalHeader,
  useDisclosure,
} from "@nextui-org/modal";
import { Spinner } from "@nextui-org/spinner";
import { Address, RewardAddress } from "@lucid-evolution/lucid";
import { Tooltip } from "@nextui-org/tooltip";

import { hackCampaign } from "../../crowdfunding";
import { CampaignUTxO } from "../../contexts/campaign/CampaignContext";
import { useWallet } from "../../contexts/wallet/WalletContext";

export default function ButtonHackClaimAllNoDatumUTXOs(props: {
  campaign: CampaignUTxO;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { campaign, onSuccess, onError } = props;

  const [walletConnection] = useWallet();
  const { isOpen, onOpen, onOpenChange } = useDisclosure();

  useEffect(() => {
    if (!isOpen) resetStates();
  }, [isOpen]);

  const [addSigner, setAddSigner] = useState<{
    yes: boolean;
    address?: Address | RewardAddress;
  }>({ yes: false });

  const [isSubmittingTx, setIsSubmittingTx] = useState(false);

  function resetStates() {
    setAddSigner({ yes: false });
    setIsSubmittingTx(false);
  }

  return (
    <>
      <Button color="success" variant="shadow" onPress={onOpen}>
        Claim All
      </Button>

      <Modal
        backdrop="blur"
        hideCloseButton={isSubmittingTx}
        isDismissable={false}
        isKeyboardDismissDisabled={isSubmittingTx}
        isOpen={isOpen}
        placement="top-center"
        onOpenChange={onOpenChange}
      >
        <ModalContent>
          {(onClose) => (
            <>
              <ModalHeader className="flex flex-col gap-1">
                Claim All No Datum UTXOs
              </ModalHeader>
              <ModalBody>
                {/* Add Signer */}
                <div className="flex flex-col gap-1">
                  <label htmlFor="signer-address">Add signer?</label>
                  <div className="flex gap-1">
                    <Checkbox
                      isDisabled={isSubmittingTx}
                      isSelected={addSigner.yes}
                      onValueChange={(isSelected) =>
                        setAddSigner((addSigner) => ({
                          ...addSigner,
                          yes: isSelected,
                        }))
                      }
                    />
                    <Tooltip
                      showArrow
                      color="primary"
                      content="Set Address to Empty to use your address."
                      id="signer-address"
                      placement="right"
                    >
                      <Input
                        isDisabled={isSubmittingTx || !addSigner.yes}
                        label="Address or Reward Address"
                        variant="bordered"
                        onValueChange={(address) =>
                          setAddSigner((addSigner) => ({
                            ...addSigner,
                            address,
                          }))
                        }
                      />
                    </Tooltip>
                  </div>
                </div>
              </ModalBody>
              <ModalFooter>
                {/* Cancel Button */}
                <div className="relative">
                  <Button
                    color="danger"
                    isDisabled={isSubmittingTx}
                    variant="flat"
                    onPress={onClose}
                  >
                    Cancel
                  </Button>
                </div>

                {/* Submit Button */}
                <div className="relative">
                  <Button
                    className={isSubmittingTx ? "invisible" : ""}
                    color="primary"
                    variant="shadow"
                    onPress={() => {
                      setIsSubmittingTx(true);
                      hackCampaign(
                        walletConnection,
                        {
                          action: "claimNoDatumUTXOs",
                          params: { addSigner, outRef: { yes: false } },
                        },
                        campaign,
                      )
                        .then(onSuccess)
                        .catch(onError)
                        .finally(onClose);
                    }}
                  >
                    Submit
                  </Button>
                  {isSubmittingTx && (
                    <Spinner className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
                  )}
                </div>
              </ModalFooter>
            </>
          )}
        </ModalContent>
      </Modal>
    </>
  );
}
