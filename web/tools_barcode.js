/**
 * Browser barcode / QR reader. Uses the native BarcodeDetector when available and
 * falls back to ZXing (loaded on demand). Driven by Flutter BarcodeScanBridgeWeb.
 */
(function () {
  const ZXING_URL = 'https://cdn.jsdelivr.net/npm/@zxing/library@0.21.3/umd/index.min.js';
  let zxingPromise = null;
  let activeScan = null;

  function emit(id, payload) {
    window.dispatchEvent(new CustomEvent('vstack-barcode-result', {
      detail: JSON.stringify({ id, ...payload }),
    }));
  }

  function message(err) {
    return String(err && err.message ? err.message : err);
  }

  function loadZxing() {
    if (window.ZXing) return Promise.resolve(window.ZXing);
    if (zxingPromise) return zxingPromise;
    zxingPromise = new Promise((resolve, reject) => {
      const s = document.createElement('script');
      s.src = ZXING_URL;
      s.async = true;
      s.onload = () => (window.ZXing ? resolve(window.ZXing) : reject(new Error('Barcode library missing')));
      s.onerror = () => {
        zxingPromise = null;
        reject(new Error('Could not load the barcode library. Check your connection.'));
      };
      document.head.appendChild(s);
    });
    return zxingPromise;
  }

  function makeReader(ZX) {
    const hints = new Map();
    hints.set(ZX.DecodeHintType.TRY_HARDER, true);
    return new ZX.BrowserMultiFormatReader(hints);
  }

  function formatName(ZX, format) {
    return (ZX.BarcodeFormat && ZX.BarcodeFormat[format]) || String(format);
  }

  async function nativeDetect(source) {
    if (!('BarcodeDetector' in window)) return null;
    try {
      const found = await new window.BarcodeDetector().detect(source);
      if (found.length) {
        return { text: found[0].rawValue, format: String(found[0].format).toUpperCase() };
      }
    } catch (_) {}
    return null;
  }

  async function decodeImage({ id, blobUrl }) {
    try {
      const img = new Image();
      img.src = blobUrl;
      await img.decode();
      const native = await nativeDetect(img);
      if (native) return emit(id, native);

      const ZX = await loadZxing();
      try {
        const result = await makeReader(ZX).decodeFromImageUrl(blobUrl);
        emit(id, { text: result.getText(), format: formatName(ZX, result.getBarcodeFormat()) });
      } catch (err) {
        if (err instanceof ZX.NotFoundException || (err && err.name === 'NotFoundException')) {
          emit(id, { notFound: true });
        } else {
          throw err;
        }
      }
    } catch (err) {
      emit(id, { error: message(err) });
    }
  }

  function cameraError(err) {
    const name = err && err.name;
    if (name === 'NotAllowedError') return 'Camera permission was denied. Allow camera access and try again.';
    if (name === 'NotFoundError' || name === 'OverconstrainedError') return 'No camera was found on this device.';
    if (name === 'NotReadableError') return 'The camera is being used by another app.';
    return message(err);
  }

  async function scanCamera({ id }) {
    if (activeScan) activeScan.close(true);
    let ZX;
    try {
      ZX = await loadZxing();
    } catch (err) {
      return emit(id, { error: message(err) });
    }

    const overlay = document.createElement('div');
    overlay.style.cssText =
      'position:fixed;inset:0;z-index:2147483647;background:rgba(6,8,15,0.96);display:flex;' +
      'flex-direction:column;align-items:center;justify-content:center;gap:18px;padding:20px;' +
      'font-family:system-ui,sans-serif;color:#EEF2FC;';
    overlay.innerHTML =
      '<div style="font-size:18px;font-weight:700">Scan a barcode or QR code</div>' +
      '<div style="position:relative;width:min(92vw,520px);aspect-ratio:4/3;max-height:65vh;border-radius:20px;' +
      'overflow:hidden;background:#000;border:1px solid rgba(255,255,255,0.14)">' +
      '<video playsinline muted autoplay style="width:100%;height:100%;object-fit:cover"></video>' +
      '<div style="position:absolute;left:10%;right:10%;top:22%;bottom:22%;border:2px solid #3B9EFF;' +
      'border-radius:14px;box-shadow:0 0 0 9999px rgba(0,0,0,0.35)"></div></div>' +
      '<div style="font-size:14px;color:#8A9BB8;text-align:center">Hold the code inside the frame. It scans automatically.</div>' +
      '<button type="button" style="padding:12px 28px;border-radius:999px;border:1px solid rgba(255,255,255,0.25);' +
      'background:transparent;color:#EEF2FC;font-size:15px;cursor:pointer">Cancel</button>';
    document.body.appendChild(overlay);

    const video = overlay.querySelector('video');
    const reader = makeReader(ZX);
    let done = false;

    function onKey(e) {
      if (e.key === 'Escape') close(true);
    }

    function close(cancelled) {
      if (done) return;
      done = true;
      try { reader.reset(); } catch (_) {}
      document.removeEventListener('keydown', onKey);
      overlay.remove();
      activeScan = null;
      if (cancelled) emit(id, { cancelled: true });
    }

    activeScan = { close };
    overlay.querySelector('button').addEventListener('click', () => close(true));
    document.addEventListener('keydown', onKey);

    try {
      await reader.decodeFromVideoDevice(undefined, video, (result) => {
        if (done || !result) return;
        const payload = { text: result.getText(), format: formatName(ZX, result.getBarcodeFormat()) };
        close(false);
        emit(id, payload);
      });
    } catch (err) {
      if (done) return;
      close(false);
      emit(id, { error: cameraError(err) });
    }
  }

  window.VStackBarcode = { isReady: true };

  window.addEventListener('vstack-barcode-op', (event) => {
    const detail = JSON.parse(event.detail);
    if (detail.op === 'decode-image') decodeImage(detail);
    else if (detail.op === 'scan-camera') scanCamera(detail);
    else emit(detail.id, { error: 'Unknown op: ' + detail.op });
  });
})();
