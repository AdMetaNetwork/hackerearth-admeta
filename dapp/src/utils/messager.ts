import * as U from './'

class Messager {
  static sendMessageToContent(type: string, data: any) {
    const target = 'admeta'
    const msg: U.T.IMessage<any> = { type, data, admeta: target }
    window.postMessage(msg, '*')
  }
}

export default Messager
