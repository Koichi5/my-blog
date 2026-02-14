import { Controller } from "@hotwired/stimulus"

// ダイアログの開閉。native <dialog> を使用。
// ラッパーに data-controller="dialog"、開くボタンに data-action="click->dialog#open"、
// <dialog> に data-dialog-target="dialog" を付与。
export default class extends Controller {
  static targets = ["dialog"]

  open() {
    if (!this.hasDialogTarget) return
    this.dialogTarget.showModal()
  }

  close() {
    if (!this.hasDialogTarget) return
    this.dialogTarget.close()
  }
}
