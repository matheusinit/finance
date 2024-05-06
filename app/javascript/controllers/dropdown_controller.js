import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['dropdown'];

  toggle() {
    if (this.dropdownTarget.classList.contains('hidden')) {
      this.dropdownTarget.classList.remove("hidden");
    } else {
      this.dropdownTarget.classList.add("hidden");
    }
  }
}
