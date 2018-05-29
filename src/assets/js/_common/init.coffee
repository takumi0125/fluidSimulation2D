projectName = 'sample'
window[projectName] = window[projectName] || {}

import log from '../_utils/log/log'
window.log = log

import Common from './Common'
document.addEventListener 'DOMContentLoaded', (e)-> new Common()
