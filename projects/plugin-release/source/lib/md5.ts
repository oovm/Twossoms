import { createHash } from 'crypto'
import { readFileSync } from 'fs'


export function fileMD5(path: string) {
    let buffer = readFileSync(path)
    let hasher = createHash('md5')
    hasher.update(buffer)
    return hasher.digest('hex')
}