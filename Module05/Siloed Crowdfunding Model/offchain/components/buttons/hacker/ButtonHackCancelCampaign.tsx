import { useEffect, useState } from "react";
import { Button } from "@nextui-org/button";
import { Checkbox } from "@nextui-org/checkbox";
import { Divider } from "@nextui-org/divider";
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
import { Tooltip } from "@nextui-org/tooltip";
import { Address, RewardAddress } from "@lucid-evolution/lucid";

import { hackCampaign } from "../../crowdfunding";
import { CampaignUTxO } from "../../contexts/campaign/CampaignContext";
import { useWallet } from "../../contexts/wallet/WalletContext";

export default function ButtonHackCancelCampaign(props: {
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

  const nowMs = new Date().getTime() * 1_000;

  const [validFrom, setValidFrom] = useState<{
    yes: boolean;
    unixTime?: number;
  }>({ yes: false });
  const [addSigner, setAddSigner] = useState<{
    yes: boolean;
    address?: Address | RewardAddress;
  }>({ yes: false });
  const [payToContract, setPayToContract] = useState<{
    yes: boolean;
    address?: string;
  }>({ yes: false });

  const [isSubmittingTx, setIsSubmittingTx] = useState(false);

  function resetStates() {
    setValidFrom({ yes: false });
    setAddSigner({ yes: false });
    setPayToContract({ yes: false });
    setIsSubmittingTx(false);
  }

  return (
    <>
      <Button color="danger" variant="flat" onPress={onOpen}>
        Cancel Campaign
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
                Cancel Campaign
              </ModalHeader>
              <ModalBody>
                {/* Valid From */}
                <div className="flex flex-col gap-1">
                  <label htmlFor="unix-time">Valid from?</label>
                  <div className="flex gap-1">
                    <Checkbox
                      isDisabled={isSubmittingTx}
                      isSelected={validFrom.yes}
                      onValueChange={(isSelected) =>
                        setValidFrom((validFrom) => ({
                          yes: isSelected,
                          unixTime: isSelected
                            ? (validFrom.unixTime ?? nowMs)
                            : undefined,
                        }))
                      }
                    />
                    <Tooltip
                      showArrow
                      color="primary"
                      content="Set UNIX Time to 0 to use the latest block time."
                      id="unix-time"
                      placement="right"
                    >
                      <Input
                        isDisabled={isSubmittingTx || !validFrom.yes}
                        label="UNIX Time"
                        placeholder={`${nowMs}`}
                        variant="bordered"
                        onValueChange={(value) =>
                          setValidFrom((validFrom) => ({
                            ...validFrom,
                            unixTime: parseInt(value),
                          }))
                        }
                      />
                    </Tooltip>
                  </div>
                </div>

                <Divider />

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

                <Divider />

                {/* Pay to Contract */}
                <div className="flex flex-col gap-1">
                  <label className="flex gap-1" htmlFor="contract-address">
                    Resend STATE_TOKEN?
                  </label>
                  <div className="flex gap-1">
                    <Checkbox
                      isDisabled={isSubmittingTx}
                      isSelected={payToContract.yes}
                      onValueChange={(isSelected) =>
                        setPayToContract((payToContract) => ({
                          ...payToContract,
                          yes: isSelected,
                        }))
                      }
                    />
                    <Tooltip
                      showArrow
                      color="primary"
                      content="Set Address to Empty to use your address."
                      id="contract-address"
                      placement="right"
                    >
                      <Input
                        isDisabled={isSubmittingTx || !payToContract.yes}
                        label="To Address"
                        variant="bordered"
                        onValueChange={(address) =>
                          setPayToContract((payToContract) => ({
                            ...payToContract,
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
                          action: "cancel",
                          params: { validFrom, addSigner, payToContract },
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
