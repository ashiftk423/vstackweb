import {
  FilesetResolver,
  HandLandmarker,
  DrawingUtils,
} from 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14';

const WASM_BASE = 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/wasm';
const MODEL_URL =
  'https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task';

/** ~15 FPS keeps laptops responsive (VIDEO mode blocks main thread). */
const DETECT_INTERVAL_MS = 66;

let landmarker = null;
let landmarkerLoading = false;

/** @type {Map<string, Session>} */
const sessions = new Map();

function emit(payload) {
  window.dispatchEvent(
    new CustomEvent('vstack-hand', {
      detail: JSON.stringify(payload),
    }),
  );
}

emit({ message: 'module_loaded', detected: false });

async function createLandmarker(useGpu) {
  const vision = await FilesetResolver.forVisionTasks(WASM_BASE);
  return HandLandmarker.createFromOptions(vision, {
    baseOptions: {
      modelAssetPath: MODEL_URL,
      delegate: useGpu ? 'GPU' : 'CPU',
    },
    runningMode: 'IMAGE',
    numHands: 1,
  });
}

async function ensureLandmarker() {
  if (landmarker) return landmarker;
  if (landmarkerLoading) {
    while (landmarkerLoading) {
      await new Promise((r) => setTimeout(r, 100));
    }
    return landmarker;
  }

  landmarkerLoading = true;
  emit({ message: 'model_loading', detected: false });

  try {
    try {
      landmarker = await createLandmarker(true);
      emit({ message: 'model_ready', detected: false, delegate: 'GPU' });
    } catch (gpuError) {
      console.warn('[VStackGesture] GPU failed, using CPU', gpuError);
      landmarker = await createLandmarker(false);
      emit({ message: 'model_ready', detected: false, delegate: 'CPU' });
    }
  } catch (err) {
    emit({ message: 'model_error', detected: false, error: String(err) });
    throw err;
  } finally {
    landmarkerLoading = false;
  }

  return landmarker;
}

function syncCanvasSize(video, canvas) {
  const w = Math.max(1, video.clientWidth || 320);
  const h = Math.max(1, video.clientHeight || 240);
  if (canvas.width !== w || canvas.height !== h) {
    canvas.width = w;
    canvas.height = h;
  }
}

function clearCanvas(session) {
  const ctx = session.canvas.getContext('2d');
  if (!ctx) return;
  syncCanvasSize(session.video, session.canvas);
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, session.canvas.width, session.canvas.height);
}

function drawVideoFrame(session) {
  const ctx = session.canvas.getContext('2d');
  if (!ctx) return false;
  syncCanvasSize(session.video, session.canvas);
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, session.canvas.width, session.canvas.height);
  try {
    ctx.drawImage(session.video, 0, 0, session.canvas.width, session.canvas.height);
    return true;
  } catch (_) {
    return false;
  }
}

function drawLandmarks(session, landmarks) {
  const ctx = session.canvas.getContext('2d');
  if (!ctx) return;
  const drawingUtils = new DrawingUtils(ctx);
  for (const hand of landmarks) {
    drawingUtils.drawConnectors(hand, HandLandmarker.HAND_CONNECTIONS, {
      color: '#00FF00',
      lineWidth: 2.5,
    });
    drawingUtils.drawLandmarks(hand, {
      color: '#FF0000',
      lineWidth: 1,
      radius: 2.5,
    });
  }
}

function updateFps(session, now) {
  session.fpsFrames += 1;
  if (now - session.fpsLastAt >= 1000) {
    session.lastFps = Math.max(
      0,
      Math.round((session.fpsFrames * 1000) / (now - session.fpsLastAt)),
    );
    session.fpsFrames = 0;
    session.fpsLastAt = now;
  }
  return session.lastFps;
}

function processResults(sessionId, session, results, now) {
  session.frameCount += 1;
  const fps = updateFps(session, now);

  emit({
    message: 'frame_tick',
    detected: false,
    sessionId,
    frame: session.frameCount,
    fps,
    handPresent: false,
  });

  const landmarks = results?.landmarks;
  const hasHand = !!(landmarks && landmarks.length > 0);

  if (!hasHand) {
    if (session.handPresent) {
      session.handPresent = false;
      session.lastIndex = null;
      session.lastPinch = null;
      emit({
        message: 'no_hand_in_frame',
        detected: false,
        sessionId,
        frame: session.frameCount,
        fps,
      });
    }
    return;
  }

  session.handPresent = true;
  drawLandmarks(session, landmarks);

  const hand = landmarks[0];
  const indexTip = hand[8];
  const thumbTip = hand[4];

  const x = 1 - indexTip.x;
  const y = indexTip.y;

  let deltaX = 0;
  let deltaY = 0;
  if (session.lastIndex) {
    deltaX = (indexTip.x - session.lastIndex.x) * -600;
    deltaY = (indexTip.y - session.lastIndex.y) * 600;
  }
  session.lastIndex = { x: indexTip.x, y: indexTip.y };

  const pinch = Math.hypot(thumbTip.x - indexTip.x, thumbTip.y - indexTip.y);
  let pinchDelta = 0;
  if (session.lastPinch != null) pinchDelta = session.lastPinch - pinch;
  session.lastPinch = pinch;

  const handedness = results.handednesses?.[0]?.[0]?.categoryName ?? 'Unknown';
  const shouldLog = now - session.lastLogAt > 600;
  if (shouldLog) session.lastLogAt = now;

  emit({
    message: 'hand_detected',
    detected: true,
    sessionId,
    frame: session.frameCount,
    fps,
    x,
    y,
    deltaX,
    deltaY,
    pinch,
    pinchDelta,
    handedness,
    landmarkCount: hand.length,
    logSample: shouldLog,
  });
}

function tick(sessionId) {
  const session = sessions.get(sessionId);
  if (!session || !landmarker) return;

  session.rafId = requestAnimationFrame(() => tick(sessionId));

  const { video } = session;
  if (video.readyState < HTMLMediaElement.HAVE_CURRENT_DATA) return;

  const now = performance.now();
  if (now - session.lastDetectAt < DETECT_INTERVAL_MS) return;
  session.lastDetectAt = now;

  try {
    if (!drawVideoFrame(session)) return;
    const results = landmarker.detect(session.canvas);
    processResults(sessionId, session, results, now);
  } catch (err) {
    session.detectErrors += 1;
    clearCanvas(session);
    session.handPresent = false;

    if (session.detectErrors <= 5 || session.detectErrors % 30 === 0) {
      emit({
        message: 'detect_error',
        detected: false,
        sessionId,
        error: String(err),
        frame: session.frameCount,
      });
    }
  }
}

async function startSession(sessionId, video, canvas) {
  if (sessions.has(sessionId)) stopSession(sessionId);

  const session = {
    video,
    canvas,
    stream: video.srcObject,
    rafId: null,
    lastIndex: null,
    lastPinch: null,
    frameCount: 0,
    lastLogAt: 0,
    fpsLastAt: performance.now(),
    fpsFrames: 0,
    lastFps: 0,
    lastDetectAt: 0,
    handPresent: false,
    detectErrors: 0,
  };

  sessions.set(sessionId, session);
  await ensureLandmarker();

  session.rafId = requestAnimationFrame(() => tick(sessionId));

  emit({ message: 'tracker_started', detected: false, sessionId, frame: 0 });
}

function stopSession(sessionId) {
  const session = sessions.get(sessionId);
  if (!session) return;
  if (session.rafId) cancelAnimationFrame(session.rafId);
  if (session.stream) {
    session.stream.getTracks().forEach((t) => t.stop());
  }
  clearCanvas(session);
  sessions.delete(sessionId);
}

async function bindContainer(sessionId, containerId) {
  const tryBind = (attempts) => {
    const container = document.getElementById(containerId);
    if (!container) {
      if (attempts < 120) {
        requestAnimationFrame(() => tryBind(attempts + 1));
      } else {
        emit({
          message: 'container_not_found',
          detected: false,
          sessionId,
          containerId,
        });
      }
      return;
    }

    startInContainer(sessionId, container).catch((err) => {
      emit({
        message: 'tracker_start_failed',
        detected: false,
        sessionId,
        error: String(err),
      });
    });
  };

  tryBind(0);
}

async function startInContainer(sessionId, container) {
  container.innerHTML = '';
  container.style.position = 'relative';
  container.style.width = '100%';
  container.style.height = '100%';
  container.style.overflow = 'hidden';
  container.style.background = '#000';

  const video = document.createElement('video');
  video.autoplay = true;
  video.muted = true;
  video.playsInline = true;
  video.setAttribute('playsinline', 'true');
  video.style.cssText =
    'position:absolute;inset:0;width:100%;height:100%;object-fit:cover;transform:scaleX(-1);opacity:0;pointer-events:none;';

  const canvas = document.createElement('canvas');
  canvas.style.cssText =
    'position:absolute;inset:0;width:100%;height:100%;transform:scaleX(-1);pointer-events:none;';

  container.appendChild(video);
  container.appendChild(canvas);

  emit({ message: 'camera_request', detected: false, sessionId });

  if (!navigator.mediaDevices?.getUserMedia) {
    emit({ message: 'camera_denied', detected: false, sessionId, error: 'getUserMedia unavailable' });
    return;
  }

  let stream;
  try {
    stream = await navigator.mediaDevices.getUserMedia({
      video: {
        facingMode: 'user',
        width: { ideal: 640, max: 1280 },
        height: { ideal: 480, max: 720 },
        frameRate: { ideal: 24, max: 30 },
      },
      audio: false,
    });
  } catch (err) {
    emit({ message: 'camera_denied', detected: false, sessionId, error: String(err) });
    return;
  }

  const tracks = stream.getVideoTracks();
  emit({
    message: 'camera_granted',
    detected: false,
    sessionId,
    tracks: tracks.length,
    label: tracks[0]?.label ?? 'unknown',
  });

  video.srcObject = stream;
  await video.play();

  await new Promise((resolve) => {
    if (video.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA) {
      resolve();
      return;
    }
    video.addEventListener('loadeddata', () => resolve(), { once: true });
    video.addEventListener('playing', () => resolve(), { once: true });
  });

  await startSession(sessionId, video, canvas);
}

window.VStackGesture = {
  bindContainer,
  stopSession,
  get isReady() {
    return !!landmarker;
  },
};

window.addEventListener('vstack-bind-camera', (event) => {
  try {
    const detail = JSON.parse(event.detail);
    const container = document.getElementById(detail.containerId);
    if (container) {
      startInContainer(detail.sessionId, container).catch((err) => {
        emit({
          message: 'tracker_start_failed',
          detected: false,
          sessionId: detail.sessionId,
          error: String(err),
        });
      });
      return;
    }
    bindContainer(detail.sessionId, detail.containerId);
  } catch (err) {
    emit({ message: 'bind_parse_error', detected: false, error: String(err) });
  }
});

window.addEventListener('vstack-unbind-camera', (event) => {
  try {
    const detail = JSON.parse(event.detail);
    stopSession(detail.sessionId);
  } catch (_) {}
});

window.addEventListener('resize', () => {
  for (const session of sessions.values()) {
    if (!session.handPresent) clearCanvas(session);
  }
});
