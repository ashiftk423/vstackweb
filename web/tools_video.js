/**
 * Browser video compressor via ffmpeg.wasm (single-thread core — no COOP/COEP required).
 * Loaded on demand by Flutter VideoToolBridgeWeb.
 */
import { FFmpeg } from 'https://cdn.jsdelivr.net/npm/@ffmpeg/ffmpeg@0.12.10/+esm';
import { fetchFile, toBlobURL } from 'https://cdn.jsdelivr.net/npm/@ffmpeg/util@0.12.1/+esm';

const ffmpeg = new FFmpeg();
let loadPromise = null;

function emitResult(id, payload) {
  window.dispatchEvent(new CustomEvent('vstack-video-result', {
    detail: JSON.stringify({ id, ...payload }),
  }));
}

function emitProgress(id, progress) {
  window.dispatchEvent(new CustomEvent('vstack-video-progress', {
    detail: JSON.stringify({ id, progress }),
  }));
}

async function ensureFfmpeg() {
  if (ffmpeg.loaded) return;
  if (loadPromise) return loadPromise;
  loadPromise = (async () => {
    const baseURL = 'https://cdn.jsdelivr.net/npm/@ffmpeg/core@0.12.6/dist/esm';
    await ffmpeg.load({
      coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript'),
      wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm'),
    });
  })();
  try {
    await loadPromise;
  } catch (err) {
    loadPromise = null;
    throw err;
  }
}

async function compress({ id, blobUrl, crf }) {
  try {
    await ensureFfmpeg();
    ffmpeg.on('progress', ({ progress }) => {
      if (typeof progress === 'number' && Number.isFinite(progress)) {
        emitProgress(id, Math.min(1, Math.max(0, progress)));
      }
    });

    const inputName = 'input.bin';
    const outputName = 'output.mp4';
    await ffmpeg.writeFile(inputName, await fetchFile(blobUrl));
    const crfValue = String(Math.min(40, Math.max(18, Number(crf) || 28)));
    await ffmpeg.exec([
      '-i', inputName,
      '-c:v', 'libx264',
      '-crf', crfValue,
      '-preset', 'fast',
      '-c:a', 'aac',
      '-b:a', '128k',
      '-movflags', '+faststart',
      '-y',
      outputName,
    ]);
    const data = await ffmpeg.readFile(outputName);
    try { await ffmpeg.deleteFile(inputName); } catch (_) {}
    try { await ffmpeg.deleteFile(outputName); } catch (_) {}

    const bytes = data instanceof Uint8Array ? data : new Uint8Array(data);
    const blob = new Blob([bytes.buffer], { type: 'video/mp4' });
    const outUrl = URL.createObjectURL(blob);
    emitResult(id, { outUrl, size: bytes.byteLength });
  } catch (err) {
    emitResult(id, { error: String(err && err.message ? err.message : err) });
  }
}

window.VStackVideo = { isReady: true };

window.addEventListener('vstack-video-op', (event) => {
  const detail = JSON.parse(event.detail);
  const { id, op } = detail;
  if (op === 'compress') compress(detail);
  else emitResult(id, { error: `Unknown op: ${op}` });
});
