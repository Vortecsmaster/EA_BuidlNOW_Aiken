import { Badge } from "@nextui-org/badge";
import { Card, CardBody, CardFooter, CardHeader } from "@nextui-org/card";
import { Divider } from "@nextui-org/divider";
import { Slider } from "@nextui-org/slider";
import { Snippet } from "@nextui-org/snippet";

import { title } from "../primitives";
import { CampaignUTxO } from "../contexts/campaign/CampaignContext";

export default function CampaignCard(props: {
  campaign: CampaignUTxO;
  hasActions?: boolean;
  actionButtons?: JSX.Element;
}) {
  const { campaign, hasActions, actionButtons } = props;
  const { CampaignInfo } = campaign;

  return (
    <Badge
      // Campaign State: Running | Cancelled | Finished
      className="!-top-1.5 !-right-3 animate-bounce"
      color={
        CampaignInfo.data.state === "Running"
          ? "primary"
          : CampaignInfo.data.state === "Cancelled"
            ? "danger"
            : CampaignInfo.data.state === "Finished"
              ? "success"
              : "default"
      }
      content={
        <span className="font-bold text-xs px-2 py-1">
          {CampaignInfo.data.state}
        </span>
      }
      showOutline={false}
      variant="shadow"
    >
      <Card id="campaign">
        {/* Campaign Info: Name, Deadline, Goal */}
        <CardHeader className="flex flex-col gap-1 items-start w-full">
          <p className={title({ size: "sm" })}>{CampaignInfo.data.name}</p>
          <p className="text-medium text-default-500">
            <label htmlFor="deadline">Deadline: </label>
            <span id="deadline">{`${CampaignInfo.data.deadline.toDateString()} ${CampaignInfo.data.deadline.toLocaleTimeString()}`}</span>
          </p>
          <Slider
            className="mt-4 mb-2"
            formatOptions={{ style: "currency", currency: "ADA" }}
            label="Goal"
            maxValue={
              CampaignInfo.data.state === "Finished" ||
              CampaignInfo.data.support.ada > CampaignInfo.data.goal
                ? CampaignInfo.data.goal
                : CampaignInfo.data.support.ada > 0
                  ? CampaignInfo.data.goal ** 2 / CampaignInfo.data.support.ada
                  : Number.POSITIVE_INFINITY
            }
            minValue={0}
            renderThumb={(props) => (
              // <div {...props} className="p-1 top-1/2 bg-primary rounded-full">
              //   <span className="transition-transform bg-background rounded-full size-3 block" />
              // </div>
              <div {...props} className="top-1/2">
                <label className="text-3xl drop-shadow">🔥</label>
              </div>
            )}
            showTooltip={CampaignInfo.data.state !== "Finished"}
            tooltipProps={{
              content: Intl.NumberFormat(navigator.languages, {
                style: "currency",
                currency: "ADA",
              }).format(CampaignInfo.data.support.ada),
              placement: "bottom",
              offset: 1.5,
            }}
            value={CampaignInfo.data.goal} // goal
          />
        </CardHeader>

        {/* Campaign ID */}
        <Divider />
        <CardBody>
          <label className="text-sm mt-2" htmlFor="campaign-id">
            Campaign ID:
          </label>
          <Snippet
            hideSymbol
            className="border-none"
            id="campaign-id"
            variant="bordered"
          >
            {CampaignInfo.id}
          </Snippet>
        </CardBody>

        {/* Campaign Actions */}
        {hasActions && (
          <>
            <Divider />
            <CardFooter className="flex justify-end">
              {actionButtons}
            </CardFooter>
          </>
        )}
      </Card>
    </Badge>
  );
}
