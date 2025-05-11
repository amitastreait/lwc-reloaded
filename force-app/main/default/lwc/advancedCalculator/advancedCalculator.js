import { LightningElement } from 'lwc';

export default class AdvancedCalculator extends LightningElement {
    expression = '';
    result = '0';

    buttons = [
        { label: '7' }, { label: '8' }, { label: '9' }, { label: '/' },
        { label: '4' }, { label: '5' }, { label: '6' }, { label: '*' },
        { label: '1' }, { label: '2' }, { label: '3' }, { label: '-' },
        { label: '0' }, { label: '.' }, { label: '=' }, { label: '+' },
    ];

    handleInputChange(event) {
        this.expression = event.target.value;
        this.evaluate();
    }

    handleButtonClick(event) {
        const val = event.target.label;

        if (val === '=') {
            this.evaluate(true);
        } else {
            this.expression += val;
            this.evaluate();
        }
    }

    handleClear() {
        this.expression = '';
        this.result = '0';
    }

    handleBackspace() {
        this.expression = this.expression.slice(0, -1);
        this.evaluate();
    }

    evaluate(final = false) {
        try {
            if (/^[0-9+\-*/.() ]*$/.test(this.expression)) {
                const res = Function(`return (${this.expression})`)();
                if (res !== undefined) {
                    this.result = res;
                }
            }
        } catch (e) {
            if (final) this.result = 'Error';
        }
    }
}