import { Constr, Data, TLiteral } from "@lucid-evolution/lucid";

//#region Alias
export const PaymentKeyHashSchema = Data.Bytes();
export const StakeKeyHashSchema = Data.Bytes();
export const AddressSchema = Data.Tuple([
  PaymentKeyHashSchema,
  StakeKeyHashSchema,
]);
//#endregion

//#region Enum
export type CampaignState = "Running" | "Cancelled" | "Finished";
export const CampaignState: Record<
  CampaignState,
  { Title: CampaignState; Schema: TLiteral<CampaignState>; Constr: Constr<[]> }
> = {
  Running: {
    Title: "Running",
    Schema: Data.Literal("Running"),
    Constr: new Constr(0, []),
  },
  Cancelled: {
    Title: "Cancelled",
    Schema: Data.Literal("Cancelled"),
    Constr: new Constr(1, []),
  },
  Finished: {
    Title: "Finished",
    Schema: Data.Literal("Finished"),
    Constr: new Constr(2, []),
  },
};
export const CampaignStateSchema = Data.Enum([
  CampaignState.Running.Schema,
  CampaignState.Cancelled.Schema,
  CampaignState.Finished.Schema,
]);
//#endregion

//#region Datum
export const CampaignDatumSchema = Data.Object({
  name: Data.Bytes(),
  goal: Data.Integer(),
  deadline: Data.Integer(),
  creator: AddressSchema,
  state: CampaignStateSchema,
});
export type CampaignDatum = Data.Static<typeof CampaignDatumSchema>;
export const CampaignDatum = CampaignDatumSchema as unknown as CampaignDatum;

export const BackerDatumSchema = AddressSchema;
export type BackerDatum = Data.Static<typeof BackerDatumSchema>;
export const BackerDatum = BackerDatumSchema as unknown as BackerDatum;
//#endregion

//#region Redeemer
export const CampaignActionRedeemer = {
  Cancel: Data.to(new Constr(0, [])),
  Finish: Data.to(new Constr(1, [])),
  Refund: Data.to(new Constr(2, [])),
};
//#endregion
