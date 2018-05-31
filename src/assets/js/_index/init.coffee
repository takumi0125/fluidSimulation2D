import Index from './Index'

projectName = 'sample'
window[projectName] = window[projectName] || {}

import log from '../_utils/log/log'
window.log = log

document.addEventListener 'DOMContentLoaded', (e)-> new Index()
