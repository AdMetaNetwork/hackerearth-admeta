import React from 'react';
import './App.css';
import {
  createClient,
  WagmiConfig
} from "wagmi";
import {
  mainnet,
  goerli,
  sepolia,
  xdc,
  xdcTestnet
} from '@wagmi/chains';
import { ConnectKitProvider, getDefaultClient } from "connectkit";
import Header from "./components/header";
import Dashboard from "./components/dashboard";

const client = createClient(
  getDefaultClient({
    appName: 'Civic Pass Eth demo',
    chains: [xdcTestnet, goerli, sepolia],
  })
)

function App() {
  return (
    <div className="App">
      <WagmiConfig client={ client }>
        <ConnectKitProvider theme="auto">
          <Header/>
          <Dashboard />
        </ConnectKitProvider>
      </WagmiConfig>
    </div>
  );
}

export default App;
