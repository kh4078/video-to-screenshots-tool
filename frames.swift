import Foundation
import AVFoundation
import AppKit

// usage: frames <video> <outdir> <interval_seconds> <maxWidth> [t0 t1 ... explicit times]
let a = CommandLine.arguments
guard a.count >= 5 else { fputs("usage: frames <video> <outdir> <interval> <maxWidth> [explicit times...]\n", stderr); exit(1) }
let url = URL(fileURLWithPath: a[1])
let outdir = a[2]
let interval = Double(a[3]) ?? 15
let maxW = Int(a[4]) ?? 600
let explicit = a.count > 5 ? a[5...].compactMap { Double($0) } : []
// 設環境變數 FRAMES_FORMAT=png 可輸出無損 PNG（精抽階段用，避免文字邊緣壓縮雜訊）
let usePNG = ProcessInfo.processInfo.environment["FRAMES_FORMAT"]?.lowercased() == "png"

try? FileManager.default.createDirectory(atPath: outdir, withIntermediateDirectories: true)

let asset = AVURLAsset(url: url)
let dur = CMTimeGetSeconds(asset.duration)
fputs("duration: \(dur)s\n", stderr)

let gen = AVAssetImageGenerator(asset: asset)
gen.appliesPreferredTrackTransform = true
gen.requestedTimeToleranceBefore = CMTime(seconds: 0.3, preferredTimescale: 600)
gen.requestedTimeToleranceAfter = CMTime(seconds: 0.3, preferredTimescale: 600)
gen.maximumSize = CGSize(width: maxW, height: maxW * 4)

var times: [Double] = []
if !explicit.isEmpty {
    times = explicit
} else {
    var t = 0.0
    while t < dur { times.append(t); t += interval }
}

for t in times {
    let cmt = CMTime(seconds: t, preferredTimescale: 600)
    do {
        let cg = try gen.copyCGImage(at: cmt, actualTime: nil)
        let rep = NSBitmapImageRep(cgImage: cg)
        let encoded = usePNG
            ? rep.representation(using: .png, properties: [:])
            : rep.representation(using: .jpeg, properties: [.compressionFactor: 0.7])
        guard let data = encoded else { continue }
        let name = String(format: usePNG ? "t%06.1f.png" : "t%06.1f.jpg", t)
        let path = (outdir as NSString).appendingPathComponent(name)
        try data.write(to: URL(fileURLWithPath: path))
        fputs("wrote \(name)\n", stderr)
    } catch {
        fputs("fail at \(t): \(error.localizedDescription)\n", stderr)
    }
}
