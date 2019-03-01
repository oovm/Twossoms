import { createWriteStream } from 'fs'
let archiver = require('archiver')
//import archiver from "archiver";


export function dirZIP(path: string, dir: string) {
    let output = createWriteStream(path)
    let archive = archiver('zip', {
        zlib: { level: 9 }
    })
    archive.pipe(output)
    archive.directory(dir, false)
    archive.finalize()
}