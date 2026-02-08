import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "count"];
  static values = { postId: Number, currentLikeId: Number };

  connect() {
    // Turboのイベントをリッスン
    document.addEventListener(
      "turbo:before-fetch-response",
      this.handleResponse.bind(this)
    );
  }

  disconnect() {
    document.removeEventListener(
      "turbo:before-fetch-response",
      this.handleResponse.bind(this)
    );
  }

  handleResponse(event) {
    const response = event.detail.fetchResponse;
    const url = response.responseURL;

    if (url && url.includes("/likes")) {
      event.preventDefault();

      response.response
        .text()
        .then((text) => {
          try {
            const data = JSON.parse(text);
            if (data && typeof data === "object" && "liked" in data) {
              this.updateLikeButton(data.liked, data.count, data.like_id);
            } else {
              window.location.reload();
            }
          } catch (e) {
            // JSONでない場合は通常のリダイレクトとして処理
            window.location.reload();
          }
        })
        .catch((error) => {
          console.error("Like action failed:", error);
          alert("いいねの処理に失敗しました。");
        });
    }
  }

  updateLikeButton(liked, count, likeId) {
    const buttonContainer = document.getElementById("like-button-container");
    const countElement = this.countTarget;
    const postId = this.postIdValue;

    if (!buttonContainer || !countElement) return;

    // ボタンを更新
    if (liked && likeId) {
      // いいね済みボタンに変更
      buttonContainer.innerHTML = `
        <form action="/posts/${postId}/likes/${likeId}" method="post" data-remote="true" data-turbo-method="delete">
          <input type="hidden" name="_method" value="delete">
          <input type="hidden" name="authenticity_token" value="${this.getCSRFToken()}">
          <button type="submit" class="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors cursor-pointer" id="like-button">
            ❤️ いいね済み
          </button>
        </form>
      `;
      this.currentLikeIdValue = likeId;
    } else {
      // いいねボタンに変更
      buttonContainer.innerHTML = `
        <form action="/posts/${postId}/likes" method="post" data-remote="true">
          <input type="hidden" name="authenticity_token" value="${this.getCSRFToken()}">
          <button type="submit" class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors cursor-pointer" id="like-button">
            🤍 いいね
          </button>
        </form>
      `;
      this.currentLikeIdValue = null;
    }

    // いいね数を更新
    countElement.textContent = `${count}件のいいね`;
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]');
    return token ? token.getAttribute("content") : "";
  }
}
