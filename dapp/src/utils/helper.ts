import * as U from './'

declare global {
  interface Window {
    mina: any
  }
}

export const formatAddress = (address: string): string => {
  if (!address) {
    return ''
  }
  const str_1 = address.substring(0, 4)
  const str_2 = address.substring(address.length - 4)
  return `${ str_1 }......${ str_2 }`
}

export const calculationAllLevel = (scoreMap: {}) => {
  const max_level = U.C.MAX_LEVEL
  let score = 0

  Object.keys(scoreMap).map((key) => {
    // @ts-ignore
    score += scoreMap[key]
  })

  return [max_level.findIndex(v => score < v) + 1, score]

}

export const calculationSingleLevel = (score: number) => {
  if (score === 0) {
    return 0
  }
  return U.C.MIN_LEVEL.findIndex(v => score < v) + 1
}
