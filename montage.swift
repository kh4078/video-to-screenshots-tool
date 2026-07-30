import Foundation
import AppKit

// usage: montage <outdir_with_jpgs> <output.jpg> <cols> <thumbW>
let a = CommandLine.arguments
guard a.count >= 5 else { fputs("usage: montage <indir> <out> <cols> <thumbW>\n", stderr); exit(1) }
let indir = a[1]; let outPath = a[2]; let cols = Int(a[3]) ?? 8; let thumbW = CGFloat(Int(a[4]) ?? 200)

let files = (try? FileManager.default.contentsOfDirectory(atPath: indir))?.filter { $0.hasSuffix(".jpg") }.sorted() ?? []
guard !files.isEmpty else { fputs("no jpgs\n", stderr); exit(1) }

// determine aspect from first
let first = NSImage(contentsOfFile: (indir as NSString).appendingPathComponent(files[0]))!
let aspect = first.size.height / first.size.width
let thumbH = thumbW * aspect
let labelH: CGFloat = 22
let pad: CGFloat = 6
let cellW = thumbW + pad
let cellH = thumbH + labelH + pad
let rows = Int(ceil(Double(files.count) / Double(cols)))
let W = cellW * CGFloat(cols)
let H = cellH * CGFloat(rows)

let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()
NSColor.white.setFill()
NSRect(x: 0, y: 0, width: W, height: H).fill()

let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
    .foregroundColor: NSColor.black
]

for (i, f) in files.enumerated() {
    let col = i % cols
    let row = i / cols
    let x = CGFloat(col) * cellW + pad/2
    // top-down: NSImage coords are bottom-left origin
    let yTop = H - CGFloat(row) * cellH
    let imgY = yTop - thumbH - pad/2
    if let thumb = NSImage(contentsOfFile: (indir as NSString).appendingPathComponent(f)) {
        thumb.draw(in: NSRect(x: x, y: imgY, width: thumbW, height: thumbH))
    }
    // label: time from filename t000123.4.jpg -> 123.4s -> mm:ss
    let base = (f as NSString).deletingPathExtension.replacingOccurrences(of: "t", with: "")
    let secs = Double(base) ?? 0
    let mm = Int(secs) / 60; let ss = Int(secs) % 60
    let label = String(format: "%d:%02d (%.0fs)", mm, ss, secs)
    label.draw(at: NSPoint(x: x, y: imgY - labelH), withAttributes: attrs)
}

img.unlockFocus()
guard let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
      let data = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
    fputs("encode fail\n", stderr); exit(1)
}
try! data.write(to: URL(fileURLWithPath: outPath))
fputs("wrote \(outPath) (\(files.count) tiles, \(cols)x\(rows))\n", stderr)
