import React, { FC, useEffect, useState } from 'react'
import LogoSVG from "./logo";
import {
  useAccount,
  useNetwork
} from "wagmi";
import { ConnectKitButton, getDefaultClient } from "connectkit";
import { GatewayProvider, IdentityButton, ButtonMode } from "@civic/ethereum-gateway-react";
import { Wallet } from 'ethers';
import * as U from '../utils'

const GATEKEEPER_NETWORK = process.env.REACT_APP_GATEKEEPER_NETWORK || "ignREusXmGrscGNUesoU9mxfds9AiYTezUKex2PsZV6";
console.log(process.env.REACT_APP_GATEKEEPER_NETWORK)

const Content = () => {
  const { address, isConnected } = useAccount()
  U.Messager.sendMessageToContent(U.C.ADMETA_MSG_HACKATHON_ACCOUNT, { address })
  const network = useNetwork()
  return <>
    { network.chain?.name && <p className={'text-black font-bold mx-4 p-2 bg-white rounded-full'}>{ network.chain.name }</p> }
    { isConnected && <IdentityButton mode={ButtonMode.LIGHT} /> }
  </>
}

const useWallet = (): Wallet | undefined => {
  const { connector, address } = useAccount();
  const [wallet, setWallet] = useState<Wallet>();
  // update the wallet if the connector or address changes
  useEffect(() => {
    if (!connector) return;
    connector.getSigner().then(setWallet);
  }, [connector, address]);

  return wallet;
}

const Gateway = () => {
  const wallet = useWallet();
  if (!wallet) return <><Content/></>

  return <GatewayProvider
    gatekeeperNetwork={ GATEKEEPER_NETWORK }
    wallet={ wallet }
  >
    <Content/>
  </GatewayProvider>
}

const Header: FC = () => {

  return (
    <div className={'flex px-4 h-20 items-center justify-between'}>
      <LogoSVG/>
      <div className={'flex items-center justify-start'}>
        <ConnectKitButton />
        <Gateway />
      </div>
    </div>
  )
}

export default Header
