import { ethers, BigNumber } from 'ethers'
import detectEthereumProvider from "@metamask/detect-provider";
import abi from "./abi";
import * as U from './'

class CallEVM {
  private signer: ethers.providers.JsonRpcSigner | undefined
  contract: ethers.Contract | undefined
  contractAddress: string

  constructor() {
    this.contractAddress = U.C.CONTRACT_ADDRESS
  }

  async init() {
    const p = await detectEthereumProvider()
    const provider = new ethers.providers.Web3Provider(p!)
    this.signer = provider.getSigner()
    const c = new ethers.Contract(this.contractAddress, abi, this.signer);
    this.contract = c.connect(this.signer)
  }

  async setUserLevel(level: BigNumber, score: BigNumber, categoryScore: string) {
    return await this.contract?.setUserLevel(level, score, categoryScore)
  }

  async getUserLevel() {
    return await this.contract?.getUserLevel()
  }

  async getUserLevelLength() {
    return await this.contract?.userLevelLength()
  }

}

export default CallEVM
