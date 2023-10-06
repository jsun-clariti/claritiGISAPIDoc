import { formatParameterizedCustomLabel, getFilteredErrorMessage, showToast, getObjIndex } from 'c/csUtils';

describe('cs-utils', () => {
    it('formatParameterizedCustomLabel: happy path', () => {
        const customLabel = 'Good {2}, "{1}". {{0}} doing "{{3}}"?';
        const valuePosMapAry = ['How are you', 'Jane', 'morning', 'today'];
        const str = formatParameterizedCustomLabel(customLabel, valuePosMapAry);

        expect(str).toBe('Good morning, Jane. How are you doing today?');
    });

    it('formatParameterizedCustomLabel: should work when the custom label has no parameters', () => {
        const customLabel = 'Good morning, Jane. How are you doing today?';
        const valuePosMapAry = ['How are you', 'Jane', 'morning', 'today'];
        const str = formatParameterizedCustomLabel(customLabel, valuePosMapAry);

        expect(str).toBe('Good morning, Jane. How are you doing today?');
    });

    it('formatParameterizedCustomLabel: should err gracefully if the valuePosMapAry param is null', () => {
        const customLabel = 'Good {2}, "{1}". {{0}} doing "{{3}}"?';
        const str = formatParameterizedCustomLabel(customLabel);

        expect(str).toBe('Good {2}, "{1}". {{0}} doing "{{3}}"?');
    });

    it('getFilteredErrorMessage: properly filtered when a string is passed in', () => {
        const msg = 'Happy Path.';
        const ret = getFilteredErrorMessage(msg);

        expect(ret).toBe('Happy Path.');
    });

    it('getFilteredErrorMessage: properly filtered when msg is an object and contains a message property', () => {
        const msg = {
            message: 'I am in a message property of an object.'
        };
        const ret = getFilteredErrorMessage(msg);

        expect(ret).toBe('I am in a message property of an object.');
    });

    it('getFilteredErrorMessage: properly filtered when msg is an object and contains a body.message property', () => {
        const msg = {
            body: {
                message: 'I am in a message property of an object.'
            }
        };
        const ret = getFilteredErrorMessage(msg);

        expect(ret).toBe('I am in a message property of an object.');
    });

    it('getObjIndex: Gets the index of the matching object with a named property', () => {
        const ary = [
            {
                id: 1,
                name: 'Mo'
            },
            {
                id: 2,
                name: 'Larry'
            },
            {
                id: 3,
                name: 'Curly'
            }
        ];

        const index = getObjIndex(ary, 'Curly', 'name');

        expect(index).toBe(2);
    });

    it('getObjIndex: Gets the index of the matching object with the default id property', () => {
        const ary = [
            {
                id: 1,
                name: 'Mo'
            },
            {
                id: 2,
                name: 'Larry'
            },
            {
                id: 3,
                name: 'Curly'
            }
        ];

        const index = getObjIndex(ary, 2);

        expect(index).toBe(1);
    });

    it('getObjIndex: Object is not in the array', () => {
        const ary = [
            {
                id: 1,
                name: 'Mo'
            },
            {
                id: 2,
                name: 'Larry'
            },
            {
                id: 3,
                name: 'Curly'
            }
        ];

        const index = getObjIndex(ary, 5);

        expect(index).toBe(-1);
    });

    it('getObjIndex: No args passed', () => {
        const index = getObjIndex();

        expect(index).toBe(-1);
    });
});
