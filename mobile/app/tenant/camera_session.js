const closedCamera = () => ({ state: 'closed', locked: false, result: null });

const permissionState = permission => {
  if (!permission) return 'loading';
  if (permission.granted) return 'ready';
  return permission.canAskAgain === false ? 'blocked' : 'denied';
};

const createCameraSession = ({ scanPayload }) => {
  let current = closedCamera();
  return {
    snapshot: () => current,
    open: permission => {
      current = { state: permissionState(permission), locked: false, result: null };
      return current;
    },
    close: () => {
      current = closedCamera();
      return current;
    },
    async receive(data) {
      if (current.state !== 'ready' || current.locked) return current;
      current = { ...current, locked: true, state: 'validating' };
      const result = await scanPayload(data);
      current = { state: result.state === 'bound' ? 'success' : 'invalid', locked: true, result };
      return current;
    }
  };
};

module.exports = { closedCamera, permissionState, createCameraSession };
