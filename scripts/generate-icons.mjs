// يولّد أيقونات PNG لتطبيق "وقتي" بدون أي مكتبات خارجية.
// الرسم: خلفية متدرجة بزوايا دائرية + وجه ساعة أبيض + علامة صح.
import { deflateSync } from 'node:zlib'
import { writeFileSync, mkdirSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')

// ---- ترميز PNG ----
const CRC_TABLE = (() => {
  const t = new Uint32Array(256)
  for (let n = 0; n < 256; n++) {
    let c = n
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1
    t[n] = c >>> 0
  }
  return t
})()

function crc32(buf) {
  let c = 0xffffffff
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8)
  return (c ^ 0xffffffff) >>> 0
}

function chunk(type, data) {
  const len = Buffer.alloc(4)
  len.writeUInt32BE(data.length)
  const body = Buffer.concat([Buffer.from(type, 'ascii'), data])
  const crc = Buffer.alloc(4)
  crc.writeUInt32BE(crc32(body))
  return Buffer.concat([len, body, crc])
}

function encodePNG(width, height, rgba) {
  const sig = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(width, 0)
  ihdr.writeUInt32BE(height, 4)
  ihdr[8] = 8 // bit depth
  ihdr[9] = 6 // RGBA
  const raw = Buffer.alloc(height * (width * 4 + 1))
  for (let y = 0; y < height; y++) {
    raw[y * (width * 4 + 1)] = 0 // filter: none
    rgba.copy(raw, y * (width * 4 + 1) + 1, y * width * 4, (y + 1) * width * 4)
  }
  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ])
}

// ---- أدوات رسم ----
function lerp(a, b, t) {
  return a + (b - a) * t
}

// المسافة من نقطة إلى قطعة مستقيمة
function segDist(px, py, x1, y1, x2, y2) {
  const dx = x2 - x1
  const dy = y2 - y1
  const l2 = dx * dx + dy * dy
  let t = l2 === 0 ? 0 : ((px - x1) * dx + (py - y1) * dy) / l2
  t = Math.max(0, Math.min(1, t))
  return Math.hypot(px - (x1 + t * dx), py - (y1 + t * dy))
}

function drawIcon(size, { maskable = false } = {}) {
  const rgba = Buffer.alloc(size * size * 4)
  const s = size
  // في النسخة القابلة للقص (maskable) نملأ كامل المربع ونصغّر الرسم للمنطقة الآمنة
  const pad = maskable ? 0 : s * 0.04
  const radius = maskable ? 0 : s * 0.22
  const scale = maskable ? 0.72 : 1
  const cx = s / 2
  const cy = s / 2
  const faceR = s * 0.32 * scale
  const ringW = s * 0.045 * scale
  // علامة الصح داخل وجه الساعة
  const ck = [
    [cx - faceR * 0.42, cy + faceR * 0.02],
    [cx - faceR * 0.1, cy + faceR * 0.36],
    [cx + faceR * 0.48, cy - faceR * 0.34],
  ]
  const ckW = s * 0.05 * scale
  // علامات الساعة (12 و 3 و 6 و 9)
  const ticks = [0, 90, 180, 270].map((deg) => {
    const a = (deg * Math.PI) / 180
    return [cx + Math.sin(a) * faceR * 0.82, cy - Math.cos(a) * faceR * 0.82]
  })

  const c1 = [15, 118, 110] // teal-700
  const c2 = [79, 70, 229] // indigo-600
  const inner = maskable ? 0 : radius

  for (let y = 0; y < s; y++) {
    for (let x = 0; x < s; x++) {
      const i = (y * s + x) * 4
      // خلفية بزوايا دائرية
      let alpha = 255
      if (!maskable) {
        const qx = Math.max(Math.abs(x - cx) - (s / 2 - pad - inner), 0)
        const qy = Math.max(Math.abs(y - cy) - (s / 2 - pad - inner), 0)
        const d = Math.hypot(qx, qy) - inner
        if (d > 0.5) alpha = 0
        else if (d > -0.5) alpha = Math.round(255 * (0.5 - d))
      }
      if (alpha === 0) {
        rgba[i + 3] = 0
        continue
      }
      const t = (x + y) / (2 * s)
      let r = lerp(c1[0], c2[0], t)
      let g = lerp(c1[1], c2[1], t)
      let b = lerp(c1[2], c2[2], t)

      // وجه الساعة: حلقة بيضاء
      const dc = Math.hypot(x - cx, y - cy)
      const ringD = Math.abs(dc - faceR) - ringW / 2
      // علامة الصح
      let ckD = Infinity
      for (let k = 0; k < ck.length - 1; k++) {
        ckD = Math.min(ckD, segDist(x, y, ck[k][0], ck[k][1], ck[k + 1][0], ck[k + 1][1]))
      }
      ckD -= ckW / 2
      // العلامات الأربع
      let tickD = Infinity
      for (const [tx, ty] of ticks) tickD = Math.min(tickD, Math.hypot(x - tx, y - ty))
      tickD -= s * 0.018 * scale

      const whiteD = Math.min(ringD, ckD, tickD)
      if (whiteD < 0.75) {
        const w = whiteD < -0.75 ? 1 : 0.5 - whiteD / 1.5
        r = lerp(r, 255, w)
        g = lerp(g, 255, w)
        b = lerp(b, 255, w)
      }
      rgba[i] = Math.round(r)
      rgba[i + 1] = Math.round(g)
      rgba[i + 2] = Math.round(b)
      rgba[i + 3] = alpha
    }
  }
  return encodePNG(s, s, rgba)
}

const outDir = join(root, 'public', 'icons')
mkdirSync(outDir, { recursive: true })
writeFileSync(join(outDir, 'icon-192.png'), drawIcon(192))
writeFileSync(join(outDir, 'icon-512.png'), drawIcon(512))
writeFileSync(join(outDir, 'icon-maskable-512.png'), drawIcon(512, { maskable: true }))
console.log('تم توليد الأيقونات في public/icons/')
