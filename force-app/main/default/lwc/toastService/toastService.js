import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labels from 'c/labelService';

export const toastStatus = {
    ERROR: 'error',
    INFO: 'info',
    SUCCESS: 'success',
    WARNING: 'warning'
};

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        // eslint-disable-next-line no-param-reassign
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter(error => !!error)
            // Extract an error message
            .map(error => {
                if (typeof error === 'string') {
                    return error;
                }
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map(e => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }

                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => {
                if (!prev.includes(curr)) {
                    return prev.concat(curr);
                }

                return prev;
            }, [])
            // Remove empty strings
            .filter(message => !!message)
    );
}

/**
 * Display the toast to user
 *
 * @param {*} component component instance or target element
 * @param {*} toastMessage Can be a string or error object
 * @param {*} toastVariant LWC toast variant
 * @param {*} toastTitle (Optional) Title for the toast
 */
export const showToast = (component, toastMessage, toastVariant, toastTitle) => {
    // Set defaults
    if (!toastVariant) {
        toastVariant = toastStatus.INFO;
    }

    if (typeof toastMessage === 'object') {
        toastMessage = reduceErrors(toastMessage).join('. ');
    }

    // Setup a default title value, if one is not specified by the caller
    if (!toastTitle) {
        switch (toastVariant.toLowerCase()) {
            case toastStatus.INFO:
                toastTitle = labels.ToastInfo;
                break;
            case toastStatus.SUCCESS:
                toastTitle = labels.ToastSuccess;
                break;
            case toastStatus.ERROR:
                toastTitle = labels.ToastError;
                break;
            case toastStatus.WARNING:
                toastTitle = labels.ToastWarning;
                break;
            default:
                toastTitle = labels.ToastError;
        }
    }

    // Throw up a toast
    component.dispatchEvent(
        new ShowToastEvent({
            title: toastTitle,
            message: '' + toastMessage,
            mode: 'dismissable',
            variant: toastVariant
        })
    );
};
