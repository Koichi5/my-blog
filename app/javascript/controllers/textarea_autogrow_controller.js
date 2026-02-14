import { Controller } from "@hotwired/stimulus"

// テキストエリアを行数に応じて自動で伸ばし、ページ全体がスクロールするようにする
export default class extends Controller {
  connect() {
    this.resize()
  }

  resize() {
    const el = this.element
    const minPx = 20 * (parseFloat(getComputedStyle(document.documentElement).fontSize) || 16)
    el.style.height = "0"
    el.style.height = `${Math.max(el.scrollHeight, minPx)}px`
  }
}
