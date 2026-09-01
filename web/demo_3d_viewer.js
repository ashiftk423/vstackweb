import * as THREE from 'https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js';
import { OrbitControls } from 'https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/controls/OrbitControls.js';
import { GLTFLoader } from 'https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/loaders/GLTFLoader.js';

const viewers = new Map();

function disposeViewer(id) {
  const v = viewers.get(id);
  if (!v) return;
  cancelAnimationFrame(v.raf);
  v.controls?.dispose();
  v.renderer?.dispose();
  if (v.container) v.container.innerHTML = '';
  viewers.delete(id);
}

async function mount(containerId, modelUrl) {
  disposeViewer(containerId);
  const container = document.getElementById(containerId);
  if (!container) return;

  const width = container.clientWidth || 640;
  const height = container.clientHeight || 480;

  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0x0a1020);

  const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100);
  camera.position.set(0, 1.2, 3);

  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  renderer.setSize(width, height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  container.appendChild(renderer.domElement);

  scene.add(new THREE.AmbientLight(0xffffff, 0.6));
  const dir = new THREE.DirectionalLight(0xffffff, 1.2);
  dir.position.set(3, 5, 2);
  scene.add(dir);

  const controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.autoRotate = true;
  controls.autoRotateSpeed = 1.5;

  const loader = new GLTFLoader();
  try {
    const gltf = await loader.loadAsync(modelUrl);
    const model = gltf.scene;
    scene.add(model);

    const box = new THREE.Box3().setFromObject(model);
    const size = box.getSize(new THREE.Vector3()).length();
    const center = box.getCenter(new THREE.Vector3());
    model.position.sub(center);
    camera.position.set(0, size * 0.3, size * 1.2);
    controls.target.set(0, 0, 0);
    controls.update();

    if (gltf.animations?.length) {
      const mixer = new THREE.AnimationMixer(model);
      gltf.animations.forEach((clip) => mixer.clipAction(clip).play());
      viewers.set(containerId, { scene, camera, renderer, controls, mixer, container, raf: 0 });
    } else {
      viewers.set(containerId, { scene, camera, renderer, controls, container, raf: 0 });
    }
  } catch (err) {
    container.innerHTML = `<p style="color:#8899aa;padding:24px;font-family:system-ui">Could not load 3D model. ${err}</p>`;
    return;
  }

  const clock = new THREE.Clock();
  function animate() {
    const v = viewers.get(containerId);
    if (!v) return;
    v.raf = requestAnimationFrame(animate);
    const delta = clock.getDelta();
    v.controls?.update();
    v.mixer?.update(delta);
    v.renderer.render(v.scene, v.camera);
  }
  animate();

  const onResize = () => {
    const v = viewers.get(containerId);
    if (!v || !container) return;
    const w = container.clientWidth || width;
    const h = container.clientHeight || height;
    v.camera.aspect = w / h;
    v.camera.updateProjectionMatrix();
    v.renderer.setSize(w, h);
  };
  window.addEventListener('resize', onResize);
  viewers.get(containerId).onResize = onResize;
}

function unmount(containerId) {
  const v = viewers.get(containerId);
  if (v?.onResize) window.removeEventListener('resize', v.onResize);
  disposeViewer(containerId);
}

window.VStack3d = { isReady: true, mount, unmount };
