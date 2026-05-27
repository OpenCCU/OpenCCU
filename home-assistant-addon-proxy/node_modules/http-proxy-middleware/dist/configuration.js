import { ERRORS } from './errors.js';
export function verifyConfig(options) {
    if (!options.target && !options.router) {
        throw new Error(ERRORS.ERR_CONFIG_FACTORY_TARGET_MISSING);
    }
}
