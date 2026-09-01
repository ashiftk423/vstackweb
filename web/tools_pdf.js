import { PDFDocument, degrees } from 'https://cdn.jsdelivr.net/npm/pdf-lib@1.17.1/+esm';

function emit(id, payload) {
  window.dispatchEvent(new CustomEvent('vstack-pdf-result', {
    detail: JSON.stringify({ id, ...payload }),
  }));
}

async function merge({ id, files }) {
  try {
    const merged = await PDFDocument.create();
    for (const b64 of files) {
      const bytes = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
      const pdf = await PDFDocument.load(bytes);
      const pages = await merged.copyPages(pdf, pdf.getPageIndices());
      pages.forEach((p) => merged.addPage(p));
    }
    const out = await merged.save();
    emit(id, { data: btoa(String.fromCharCode(...out)) });
  } catch (err) {
    emit(id, { error: String(err) });
  }
}

async function split({ id, file }) {
  try {
    const bytes = Uint8Array.from(atob(file), (c) => c.charCodeAt(0));
    const pdf = await PDFDocument.load(bytes);
    const pages = [];
    for (let i = 0; i < pdf.getPageCount(); i++) {
      const doc = await PDFDocument.create();
      const [page] = await doc.copyPages(pdf, [i]);
      doc.addPage(page);
      const out = await doc.save();
      pages.push(btoa(String.fromCharCode(...out)));
    }
    emit(id, { pages });
  } catch (err) {
    emit(id, { error: String(err) });
  }
}

async function imagesToPdf({ id, images }) {
  try {
    const doc = await PDFDocument.create();
    for (const b64 of images) {
      const bytes = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
      let img;
      try {
        img = await doc.embedPng(bytes);
      } catch (_) {
        img = await doc.embedJpg(bytes);
      }
      const page = doc.addPage([img.width, img.height]);
      page.drawImage(img, { x: 0, y: 0, width: img.width, height: img.height });
    }
    const out = await doc.save();
    emit(id, { data: btoa(String.fromCharCode(...out)) });
  } catch (err) {
    emit(id, { error: String(err) });
  }
}

window.VStackPdf = { isReady: true };

window.addEventListener('vstack-pdf-op', (event) => {
  const detail = JSON.parse(event.detail);
  const { id, op } = detail;
  if (op === 'merge') merge(detail);
  else if (op === 'split') split(detail);
  else if (op === 'imagesToPdf') imagesToPdf(detail);
  else emit(id, { error: `Unknown op: ${op}` });
});
