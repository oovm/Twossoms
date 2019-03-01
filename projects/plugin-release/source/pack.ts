import { dirZIP } from './lib'
import { resolve, join } from 'path'
import { readFileSync } from 'fs'
const $here = resolve(__dirname, '../..')
const $release = resolve(__dirname, '../../../release')

const projects = [
    'database-idiom'
]

function packer(project: string) {
    const there = join($here, project, 'release')
    const record = JSON.parse(readFileSync(join(there, 'record.json'), 'utf8'))
    const zip = record.name + '-v' + record.version.join('.') + '.zip'
    dirZIP(join($release, zip), there)
}

export function pack() { projects.map(packer) } 