import { useEffect, useState } from "react";
import {
  fromAbsolute,
  getLocalTimeZone,
  now,
  ZonedDateTime,
} from "@internationalized/date";
import { Button } from "@nextui-org/button";
import { DatePicker } from "@nextui-org/date-picker";
import { Input } from "@nextui-org/input";
import {
  Modal,
  ModalBody,
  ModalContent,
  ModalFooter,
  ModalHeader,
  useDisclosure,
} from "@nextui-org/modal";
import { Skeleton } from "@nextui-org/skeleton";
import { Spinner } from "@nextui-org/spinner";

import { CampaignUTxO } from "../../contexts/campaign/CampaignContext";

import { koios } from "@/components/providers/koios";
import { adaToLovelace, handleError } from "@/components/utils";
import { createCampaign } from "@/components/crowdfunding";
import { useWallet } from "@/components/contexts/wallet/WalletContext";

export default function ButtonCreateCampaign(props: {
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { onSuccess, onError } = props;

  const [walletConnection] = useWallet();
  const { isOpen, onOpen, onOpenChange } = useDisclosure();

  useEffect(() => {
    if (isOpen) {
      koios
        .getBlockTimeMs()
        .then((now) => {
          return setBlockTime(() => {
            return fromAbsolute(now, timezone);
          });
        })
        .catch(handleError);
    } else {
      setIsSubmittingTx(false);
      resetStates();
    }
  }, [isOpen]);

  const timezone = getLocalTimeZone();
  const [blockTime, setBlockTime] = useState<ZonedDateTime | null>();

  const [campaignName, setCampaignName] = useState("");
  const [campaignGoal, setCampaignGoal] = useState("");
  const [campaignDeadline, setCampaignDeadline] = useState(blockTime);

  const [goal, setGoal] = useState(0n);
  const [deadline, setDeadline] = useState(0n);

  useEffect(() => {
    setGoal(() => {
      try {
        return adaToLovelace(campaignGoal);
      } catch {
        return 0n;
      }
    });
  }, [campaignGoal]);

  useEffect(() => {
    setDeadline(() => {
      try {
        return BigInt(campaignDeadline?.toDate().getTime() ?? 0);
      } catch {
        return 0n;
      }
    });
  }, [campaignDeadline]);

  const isValidCampaign = () => campaignName && goal > 0n && deadline > 0n;
  const [isSubmittingTx, setIsSubmittingTx] = useState(false);

  function resetStates() {
    setCampaignName("");
    setCampaignGoal("");
    setCampaignDeadline(undefined);
    setBlockTime(undefined);
  }

  return (
    <>
      <Button
        className="w-fit"
        color="primary"
        radius="full"
        variant="shadow"
        onPress={() => {
          const crowdfundingPlatform = localStorage.getItem(
            "CrowdfundingPlatform",
          );

          if (crowdfundingPlatform) onOpen();
          else
            handleError(
              "Go to Admin page to set the Crowdfunding Platform Address first!",
            );
        }}
      >
        Create Campaign
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
                Create Campaign
              </ModalHeader>
              <ModalBody>
                {/* Campaign Name */}
                <Skeleton className="rounded-xl" isLoaded={!!blockTime}>
                  <Input
                    autoFocus
                    isDisabled={isSubmittingTx}
                    label="Campaign Name"
                    placeholder="Enter campaign name"
                    onValueChange={setCampaignName}
                  />
                </Skeleton>

                {/* Campaign Goal */}
                <Skeleton className="rounded-xl" isLoaded={!!blockTime}>
                  <Input
                    isDisabled={isSubmittingTx}
                    label="Campaign Goal"
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
                    onValueChange={setCampaignGoal}
                  />
                </Skeleton>

                {/* Campaign Deadline */}
                <Skeleton className="rounded-xl" isLoaded={!!blockTime}>
                  <DatePicker
                    hideTimeZone
                    showMonthAndYearPickers
                    defaultValue={now(timezone)}
                    isDisabled={isSubmittingTx}
                    label="Set Deadline"
                    minValue={blockTime}
                    onChange={setCampaignDeadline}
                  />
                </Skeleton>
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
                    isDisabled={!isValidCampaign()}
                    variant="shadow"
                    onPress={() => {
                      setIsSubmittingTx(true);
                      createCampaign(walletConnection, {
                        name: campaignName,
                        goal,
                        deadline,
                      })
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
