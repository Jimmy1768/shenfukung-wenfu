const { scanFixture } = require('./binding');

const createQrScanner = ({ readPayload }) => ({
  kind: 'native_qr_interface',
  async scanConnection() {
    const payload = await readPayload();
    return scanFixture(payload);
  }
});

const createFixtureQrScanner = payload => createQrScanner({ readPayload: () => payload });

const scanCameraPayload = async ({ mode, payload }) => {
  if (mode !== 'dummy') return { state: 'binding_failed', tenant: null, error: 'real_camera_binding_deferred', source: 'qr' };
  return createFixtureQrScanner(payload).scanConnection();
};

module.exports = { createQrScanner, createFixtureQrScanner, scanCameraPayload };
