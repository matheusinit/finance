import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['password', 'passwordConfirmation'];

  toggle() {
    const passwordField = this.passwordTarget;

    if (passwordField.type === 'password') {
      passwordField.type = 'text';
    } else {
      passwordField.type = 'password';
    }
  }

  togglePasswordConfirmation() {
    const passwordConfirmationField = this.passwordConfirmationTarget;

    if (passwordConfirmationField.type === 'password') {
      passwordConfirmationField.type = 'text';
    } else {
      passwordConfirmationField.type = 'password';
    }
  }
}
