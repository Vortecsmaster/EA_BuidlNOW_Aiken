import { useEffect } from "react";

import { useWallet } from "@/components/contexts/wallet/WalletContext";
import { title, subtitle } from "@/components/primitives";

import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

import { Link } from "@nextui-org/link";
import { Lucid } from "@lucid-evolution/lucid";

import { network, provider } from "@/config/lucid";
import WalletConnectors from "@/components/pages/home/WalletConnectors";
import ConnectedDashboard from "@/components/pages/home/ConnectedDashboard";
import DisconnectButton from "@/components/pages/DisconnectButton";

export default function Home() {
  const [walletConnection, setWalletConnection] = useWallet();
  const { address } = walletConnection;

  let isInit = false;

  useEffect(() => {
    if (isInit) return;
    else isInit = true;

    Lucid(provider, network)
      .then((lucid) =>
        setWalletConnection((walletConnection) => {
          return { ...walletConnection, lucid };
        }),
      )
      .catch((error) => toast(`${error}`, { type: "error" }));
  }, []);

  if (address)
    return (
      <section className="relative flex flex-col items-center justify-center gap-4 py-8 md:py-10">
        <ConnectedDashboard />
        <DisconnectButton />
        <ToastContainer position="bottom-right" theme="dark" />
      </section>
    );

  return (
    <section className="flex flex-col items-center justify-center gap-4 py-8 md:py-10">
      {/* Title */}
      <div className="inline-block max-w-xl text-center justify-center">
        <span className={title()}>Connect&nbsp;</span>
        <span className={title({ color: "violet" })}>Cardano&nbsp;</span>
        <span className={title()}>Wallet</span>
      </div>

      {/* Wallet Connectors */}
      <div className="flex justify-center mt-4 w-full">
        <WalletConnectors />
      </div>

      {/* Subtitle */}
      <div className="inline-block max-w-xl text-center justify-center">
        <div className={subtitle({ class: "mt-4" })}>
          See the{" "}
          <Link
            isExternal
            className="text-lg lg:text-xl"
            href="https://developers.cardano.org/showcase/?tags=wallet"
          >
            list of wallets
          </Link>{" "}
          built for Cardano
        </div>
      </div>

      {/* Toast */}
      <ToastContainer position="bottom-right" theme="dark" />
    </section>
  );
}
