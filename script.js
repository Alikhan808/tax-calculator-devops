import { calculateTax } from './taxCalculator.js';

const form = document.querySelector('#tax-form');
const input = document.querySelector('#valBox');
const currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

function showResult(income, calculated) {
  const tax = calculated ? calculateTax(income) : 0;
  document.querySelector('#final-amount').textContent = tax.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  document.querySelector('#income-result').textContent = currency.format(income);
  document.querySelector('#net-result').textContent = currency.format(income - tax);
  document.querySelector('#tax-perc').textContent = income === 0 ? '0.00' : (100 * tax / income).toFixed(2);
  document.querySelector('#calculation-status').textContent = calculated
    ? 'Calculation complete using the course tax schedule.'
    : 'Enter your income and select Calculate tax.';
}

form.addEventListener('submit', event => {
  event.preventDefault();
  if (!form.reportValidity()) return;
  showResult(Number(input.value), true);
});

form.addEventListener('reset', event => {
  event.preventDefault();
  input.value = '0';
  showResult(0, false);
  input.focus();
});
