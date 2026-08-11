const { scanFixture } = require('./binding');

const createQrScanner = ({ readPayload }) => ({
  kind: 'native_qr_interface',
  async scanConnection() {
    const payload = await readPayload();
    return scanFixture(payload);
  }
});

const createFixtureQrScanner = payload => createQrScanner({ readPayload: () => payload });

module.exports = { createQrScanner, createFixtureQrScanner };
