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
import { Tooltip } from "@nextui-org/tooltip";

import { hackCampaign } from "../../crowdfunding";
import { CampaignUTxO } from "../../contexts/campaign/CampaignContext";
import { useWallet } from "../../contexts/wallet/WalletContext";

import { adaToLovelace } from "@/components/utils";

export default function ButtonHackRefundCampaign(props: {
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

  const [payToAddress, setPayToAddress] = useState<{
    yes: boolean;
    address?: string;
    lovelace?: bigint;
  }>({ yes: false });

  const [isSubmittingTx, setIsSubmittingTx] = useState(false);

  function resetStates() {
    setPayToAddress({ yes: false });
    setIsSubmittingTx(false);
  }

  return (
    <>
      <Button color="warning" variant="flat" onPress={onOpen}>
        Refund Campaign
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
                Refund Campaign
              </ModalHeader>
              <ModalBody>
                {/* Pay to Address */}
                <div className="flex flex-col gap-1">
                  <label className="flex gap-1" htmlFor="support-address">
                    Send backer supports?
                  </label>
                  <div className="flex gap-1">
                    <Checkbox
                      isDisabled={isSubmittingTx}
                      isSelected={payToAddress.yes}
                      onValueChange={(isSelected) =>
                        setPayToAddress((payToAddress) => ({
                          ...payToAddress,
                          yes: isSelected,
                        }))
                      }
                    />
                    <Input
                      id="support-address"
                      isDisabled={isSubmittingTx || !payToAddress.yes}
                      label="To Address"
                      variant="bordered"
                      onValueChange={(address) =>
                        setPayToAddress((payToAddress) => ({
                          ...payToAddress,
                          address,
                        }))
                      }
                    />
                    <Tooltip
                      showArrow
                      color="primary"
                      content="Set ADA to 0 to send all backer support amount."
                      id="support-lovelace"
                      placement="right"
                    >
                      <Input
                        isDisabled={isSubmittingTx || !payToAddress.yes}
                        label="Support Amount"
                        max={45_000_000_000.0}
                        min={0}
                        placeholder="0.000000"
                        startContent={
                          <div className="pointer-events-none flex items-center">
                            <span className="text-default-400 text-small">
                              ADA
                            </span>
                          </div>
                        }
                        step={1}
                        type="number"
                        variant="bordered"
                        onValueChange={(value) =>
                          setPayToAddress((payToAddress) => ({
                            ...payToAddress,
                            lovelace: adaToLovelace(value),
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
                        { action: "refund", params: { payToAddress } },
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
