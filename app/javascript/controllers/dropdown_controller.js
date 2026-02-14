import { Controller } from "@hotwired/stimulus"

// ドロップダウンメニューの開閉。トリガー外クリックで閉じる。
export default class extends Controller {
  static targets = ["menu", "trigger"]

  connect() {
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this)
  }

  toggle() {
    if (!this.hasMenuTarget) return
    const isOpen = this.menuTarget.classList.contains("nav-dropdown-open")
    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasMenuTarget) return
    this.menuTarget.classList.add("nav-dropdown-open")
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.boundCloseOnClickOutside, true)
  }

  close() {
    if (!this.hasMenuTarget) return
    this.menuTarget.classList.remove("nav-dropdown-open")
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this.boundCloseOnClickOutside, true)
  }

  closeOnClickOutside(event) {
    if (this.element.contains(event.target)) return
    this.close()
  }
}
