import { useState } from "react";
import { Button } from "@nextui-org/button";
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

import { useWallet } from "../../contexts/wallet/WalletContext";
import { CampaignUTxO } from "../../contexts/campaign/CampaignContext";
import { supportCampaign } from "../../crowdfunding";
import { handleError } from "../../utils";

export default function ButtonSupportCampaign(props: {
  campaign: CampaignUTxO;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { campaign, onSuccess, onError } = props;

  const [walletConnection] = useWallet();

  const { isOpen, onOpen, onOpenChange } = useDisclosure();

  const [supportAmount, setSupportAmount] = useState("");
  const [isSubmittingTx, setIsSubmittingTx] = useState(false);

  return (
    <>
      <Button
        className="w-fit"
        color="secondary"
        variant="shadow"
        onPress={onOpen}
      >
        Support Campaign
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
                Support Campaign
              </ModalHeader>
              <ModalBody>
                <Input
                  isDisabled={isSubmittingTx}
                  label="Support Amount"
                  max={45_000_000_000.0}
                  min={0}
                  placeholder="0.000000"
                  startContent={
                    <div className="pointer-events-none flex items-center">
                      <span className="text-default-400 text-small">ADA</span>
                    </div>
                  }
                  step={1}
                  type="number"
                  onValueChange={setSupportAmount}
                />
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
                      supportCampaign(walletConnection, campaign, supportAmount)
                        .then(onSuccess)
                        .catch(onError ?? handleError)
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
