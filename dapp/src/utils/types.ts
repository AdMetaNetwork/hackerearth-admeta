type Status = 'idle' | 'loading' | 'success' | 'error'

interface Meta {
  genesisHash: string
  name: string
  source: string
}

interface Wallet {
  address: string
  meta: Meta
  type: string
}

interface IMessage<T> {
  type: string
  data: T,
  admeta: 'admeta'
}


export {
  type Status,
  type Wallet,
  type IMessage
}
