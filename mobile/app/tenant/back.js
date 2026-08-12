const resolveHardwareBack = ({ screen, cameraOpen }) => {
  if (cameraOpen) return { handled: true, screen: 'home', cameraOpen: false };
  if (screen !== 'home') return { handled: true, screen: 'home', cameraOpen: false };
  return { handled: false, screen, cameraOpen: false };
};

module.exports = { resolveHardwareBack };
