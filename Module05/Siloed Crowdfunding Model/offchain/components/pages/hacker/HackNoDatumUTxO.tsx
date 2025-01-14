import { Card, CardBody, CardFooter, CardHeader } from "@nextui-org/card";
import { Divider } from "@nextui-org/divider";
import {
  Table,
  TableBody,
  TableCell,
  TableColumn,
  TableHeader,
  TableRow,
} from "@nextui-org/table";
import { UTxO } from "@lucid-evolution/lucid";

import ButtonHackClaimNoDatumUTxO from "@/components/buttons/hacker/ButtonHackClaimNoDatum";
import { CampaignUTxO } from "@/components/contexts/campaign/CampaignContext";

export default function HackNoDatumUTxO(props: {
  utxo: UTxO;
  campaign: CampaignUTxO;
  onSuccess: (campaign: CampaignUTxO) => void;
  onError?: (error: any) => void;
}) {
  const { utxo, campaign, onSuccess, onError } = props;
  const oRef = `${utxo.txHash}#${utxo.outputIndex}`;

  return (
    <Card id={oRef}>
      {/* UTxO OutputReference */}
      <CardHeader className="flex flex-col gap-1 items-start w-full">
        <p className="font-bold text-xs">{oRef}</p>
        {/* <p className="text-medium text-default-500">
          <label htmlFor="utxo-assets">Assets: </label>
          <span id="utxo-assets">{`${utxo.assets}`}</span>
        </p> */}
      </CardHeader>

      {/* UTxO Assets */}
      <Divider />
      <CardBody className="text-sm">
        <label htmlFor="utxo-assets">Assets:</label>
        <Table hideHeader isStriped aria-label="UTxO Assets" id="utxo-assets">
          <TableHeader>
            <TableColumn>Asset</TableColumn>
            <TableColumn>Amount</TableColumn>
          </TableHeader>
          <TableBody>
            {Object.keys(utxo.assets).map((unit) => (
              <TableRow key={unit}>
                <TableCell>{unit === "lovelace" ? "ADA" : unit}</TableCell>
                <TableCell>
                  {Intl.NumberFormat(navigator.languages, {
                    minimumFractionDigits: unit === "lovelace" ? 2 : 0,
                  }).format(
                    unit === "lovelace"
                      ? parseFloat(
                          `${utxo.assets[unit] / 1_000000n}.${utxo.assets[unit] % 1_000000n}`,
                        )
                      : utxo.assets[unit],
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardBody>

      {/* Claim Button */}
      <Divider />
      <CardFooter className="flex justify-end">
        <ButtonHackClaimNoDatumUTxO
          campaign={campaign}
          utxo={utxo}
          onError={onError}
          onSuccess={onSuccess}
        />
      </CardFooter>
    </Card>
  );
}
