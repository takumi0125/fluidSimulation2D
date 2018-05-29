// isiOS
import isiPad   from './isiPad';
import isiPhone from './isiPhone';
import isiPod   from './isiPod';

export default (function() {
  return isiPad || isiPhone || isiPod;
})();
