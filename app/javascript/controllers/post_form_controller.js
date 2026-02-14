import { Controller } from "@hotwired/stimulus"

// 新規投稿フォーム: 下書きトグルと投稿/保存ボタン文言の連動
export default class extends Controller {
  static targets = ["draftToggle", "statusInput", "submitBtn"]

  connect() {
    this.updateState()
  }

  toggle() {
    this.updateState()
  }

  updateState() {
    if (!this.hasDraftToggleTarget || !this.hasStatusInputTarget) return
    const isDraft = this.draftToggleTarget.checked
    this.statusInputTarget.value = isDraft ? "draft" : "published"
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.textContent = isDraft ? "投稿" : "保存"
    }
  }
}
