import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["editor"];

  connect() {
    this.element.addEventListener("dragover", this.handleDragOver.bind(this));
    this.element.addEventListener("drop", this.handleDrop.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("dragover", this.handleDragOver.bind(this));
    this.element.removeEventListener("drop", this.handleDrop.bind(this));
  }

  handleDragOver(e) {
    e.preventDefault();
    e.stopPropagation();
    this.element.style.backgroundColor = "#f0f0f0";
  }

  handleDragLeave(e) {
    e.preventDefault();
    e.stopPropagation();
    this.element.style.backgroundColor = "";
  }

  async handleDrop(e) {
    e.preventDefault();
    e.stopPropagation();
    this.element.style.backgroundColor = "";

    const files = Array.from(e.dataTransfer.files);
    for (const file of files) {
      if (file.type.startsWith("image/") || file.type.startsWith("video/")) {
        await this.uploadFile(file);
      }
    }
  }

  async uploadFile(file) {
    const upload = new DirectUpload(
      file,
      "/rails/active_storage/direct_uploads",
      this
    );

    upload.create((error, blob) => {
      if (error) {
        console.error("Upload error:", error);
        alert("アップロードに失敗しました: " + error);
        return;
      }

      const url = `/rails/active_storage/blobs/${blob.signed_id}/${blob.filename}`;
      const markdown = file.type.startsWith("image/")
        ? `![${file.name}](${url})`
        : `[${file.name}](${url})`;

      // MarkdownエディタにURLを挿入
      this.insertMarkdown(markdown);
    });
  }

  insertMarkdown(markdown) {
    const editor = this.editorTarget;
    if (!editor) {
      console.error("Editor target not found");
      return;
    }

    const start = editor.selectionStart;
    const end = editor.selectionEnd;
    const text = editor.value;
    const newText =
      text.substring(0, start) + markdown + "\n" + text.substring(end);

    editor.value = newText;
    editor.selectionStart = editor.selectionEnd = start + markdown.length + 1;
    editor.focus();
  }

  // DirectUpload callbacks
  directUploadWillStoreFileWithXHR(xhr) {
    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        const percentComplete = (event.loaded / event.total) * 100;
        console.log(`Upload progress: ${percentComplete.toFixed(0)}%`);
      }
    });
  }
}

