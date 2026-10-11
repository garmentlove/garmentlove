import { Controller } from "@hotwired/stimulus"

// data-controller="theme"
export default class extends Controller {
  static targets = [ ]
  static values = { 
    storageKey: { type: String, default: "theme" },
    defaultTheme: { type: String, default: "system" }
  }

  connect() {
    this.#setTheme()
    this.#matchMedia().addEventListener("change", this.#setTheme.bind(this))
  }

  toggle() {
    const theme = this.#toggleAttribute
    this.#applyTheme(theme)
    this.#themeStore = theme
  }

  reset() {
    this.#themeStore = this.defaultThemeValue
    this.#setTheme()
  }

  set({ target: { value } }) {  
    this.#themeStore = value
    this.#setTheme()
  }

  #applyTheme(theme) {
    this.#dataThemeAttribute = theme
  }

  #setTheme() {
    if (this.#themeStore != null && this.#themeStore != this.defaultThemeValue) {
      return this.#applyTheme(this.#themeStore)
    }

    this.#applyTheme(this.#matchMedia().matches ? "dark" : "light")
  }

  #matchMedia() {
    return window.matchMedia("(prefers-color-scheme: dark)")
  }

  get #toggleAttribute() {
    return (this.#dataThemeAttribute === "dark" ? "light" : "dark")
  }

  get #dataThemeAttribute() {
    return this.element.getAttribute("data-theme")
  }

  set #dataThemeAttribute(value) {
    this.element.setAttribute("data-theme", value)
  }

  set #themeStore(value) {
    localStorage.setItem(this.storageKeyValue, value)
  }

  get #themeStore() {
    return localStorage.getItem(this.storageKeyValue)
  }
}
