import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * Converts characters that act as parameters in Custom Labels.
 *
 * Example:
 *
 * let customLabel = 'Good {2}, "{1}". {{0}} doing "{{3}}"?';
 * let valuePosMapAry = ['How are you', 'Jane', 'morning', 'today'];
 * let str = formatParameterizedCustomLabel(customLabel, valuePosMapAry);
 *
 * // returns: 'Good morning, Jane. How are you doing today?'
 *
 * @param  {string} customLabel Initial string that may contain placeholders that match the pattern of "{0}", {0}, "{{0}}", or {{0}}
 * @param  {array}  valuePosMapAry Array of strings that map to the integer value inside each placeholder.
 * @return {string} String replaced with any matching values that exist in valuePosMapAry.
 */
export function formatParameterizedCustomLabel(customLabel = '', valuePosMapAry = []) {
    const regex = /"\{(\d+)\}"|\{\{(\d+)\}\}|"\{\{(\d+)\}\}"|\{(\d+)\}/g;
    const chars = /\{|\}|"\{|\}"/g;
    const matches = customLabel.match(regex);

    if (matches !== null && valuePosMapAry.length > 0) {
        const matchIndices = matches.map(match => {
            return parseInt(match.replace(chars, ''), 10);
        });

        matches.forEach((valToReplace, i) => {
            customLabel = customLabel.replace(valToReplace, valuePosMapAry[matchIndices[i]]);
        });
    }

    return customLabel;
}

/**
 * Sometimes the backend returns an error message that is nested. This retrieves the message.
 *
 * @param  {object, string} msg Could be an object or a string
 * @return {string} Unpacked message
 */
export function getFilteredErrorMessage(msg = '') {
    if (msg.hasOwnProperty('message')) {
        return msg.message;
    }

    if (msg.hasOwnProperty('body') && msg.body.hasOwnProperty('message')) {
        return msg.body.message;
    }

    return msg;
}
/**
 * Fires platform ShowToastEvent to give users a notification of something that has happened.
 *
 * @param  {object} eventTarget The value of 'this' from the caller
 * @param  {string} title Title of the toast
 * @param  {string} message Message body of the toast
 * @param  {string} variant Possible variants are info, success, warning, and error
 * @param  {string} mode Possible modes are dismissable, sticky, and pester
 * @return {void}
 */
export function showToast(eventTarget, title = '', message = '', variant = 'info', mode = 'dismissable') {
    const evt = new ShowToastEvent({
        title,
        message: getFilteredErrorMessage(message),
        variant,
        mode
    });

    eventTarget.dispatchEvent(evt);
}

/**
 * Get the index of the matching object property. If the property exists in the
 * array of objects, it will return the index. Otherwise, it will return -1
 *
 * Example:
 *
 * let ary = [{id: 'foo'}, {id: 'bar'}];
 * let index = getObjIndex(ary, 'bar');
 * // returns: 1
 *
 * OR:
 *
 * let ary = [{name: 'foo'}, {name: 'bar'}];
 * let index = getObjIndex(ary, 'bar', 'name');
 * // returns: 1
 *
 * @param  {array} ary Array of objects
 * @param  {object} val Value to be searched in the given array of objects
 * @param  {string} prop Property of object to be searched. This param is not required and will default to 'id'.
 * @return {integer} 0 or greater (the actual index of the array) if true and -1 if false
 */
export function getObjIndex(ary = [], val = '', prop = 'id') {
    return ary
        .map(item => {
            return item[prop];
        })
        .indexOf(val);
}

/**
 * Proxy objects are unreadable in the console. During development, this method will allow
 * one to view Proxy object content in the browser dev console.
 *
 * Note: use this method only during development. Strip it out before going to production.
 *
 * @param {Object} proxyObj Proxy object to be logged
 * @param {String} title Title of log
 * @param {Array} colorConfig Optional to customize color of log (i.e., ['black','orange'])
 */
export function logProxy(proxyObj = {}, title = 'Log Proxy', colorConfig = ['#222', '#fff']) {
    console.info(
        `%c${title}`,
        `background-color: ${colorConfig[0]}; color: ${colorConfig[1]}; padding: 0.5rem;`,
        JSON.parse(JSON.stringify(proxyObj))
    );
}

/**
 * generates a uuid for use on the client.  i.e. used as keys for list iteration
 */
export function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = (Math.random() * 16) | 0,
            v = c === 'x' ? r : (r & 0x3) | 0x8;
        return v.toString(16);
    });
}

/**
 * FOR HELLO-DX REPO: Adding this here to trigger the CSMD warning output
 * console.log('console logs should be avoided');
 */
