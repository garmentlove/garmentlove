import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lineItemsFrame", "itemTemplate", "weeklyFields", "total", "summaryLines", "summaryEmpty"]

  connect() {
    this.itemIndex = 0
    this.changeType()
    this.toggleWeekly()
    this.refreshTotal()
  }

  changeType() {
    const fulfillmentDate = this.element.querySelector('input[name="order[fulfillment_date]"]')
    if (fulfillmentDate) fulfillmentDate.required = this.activePanel()?.dataset.orderType === "rental"
    this.refreshTotal()
  }

  frameLoaded() {
    this.changeType()
    this.toggleWeekly()
  }

  toggleWeekly() {
    const toggle = this.element.querySelector('input[type="checkbox"][name="order[weekly_preset]"]')
    if (!toggle || !this.hasWeeklyFieldsTarget) return

    this.weeklyFieldsTarget.hidden = !toggle.checked
    this.weeklyFieldsTarget.querySelectorAll("select").forEach((field) => {
      field.required = toggle.checked
    })
  }

  addItem(event) {
    const activePanel = this.activePanel()
    if (!activePanel) return

    const template = activePanel.querySelector("template")
    const list = activePanel.querySelector(".gl-pos-item-list")
    if (!template || !list) return

    const index = this.itemIndex++
    const markup = template.innerHTML.replaceAll("NEW_RECORD", index)
    list.insertAdjacentHTML("beforeend", markup)
    const item = list.lastElementChild
    item.querySelector("[data-item-entry-target='barcodeInput']")?.focus()
    this.refreshTotal()
  }

  removeItem(event) {
    event.currentTarget.closest("[data-line-item]")?.remove()
    this.refreshTotal()
  }

  validateItems(event) {
    const incompleteItem = this.element.querySelector('[data-line-item]:not([data-item-entry-stage="details"])')
    if (incompleteItem) {
      event.preventDefault()
      incompleteItem.dispatchEvent(new Event("item-entry:show-details"))
      incompleteItem.scrollIntoView({ behavior: "smooth", block: "center" })
      return
    }

    for (const item of this.element.querySelectorAll("[data-line-item]")) {
      const catalog = item.querySelector('select[name$="[item_id]"]')
      const name = item.querySelector('input[name$="[name]"]')
      const quantity = item.querySelector('input[name$="[quantity]"]')
      const weight = item.querySelector('input[name$="[weight]"]')
      const invalidField = weight && !weight.value
        ? weight
        : (quantity && Number(quantity.value) < 1
          ? quantity
          : (!catalog?.value && name && !name.value.trim() ? name : null))

      if (!invalidField) continue

      event.preventDefault()
      invalidField.setCustomValidity(
        invalidField === weight
          ? "Enter the wash and fold weight."
          : (invalidField === quantity ? "Quantity must be at least one." : "Select a catalog item or enter an item name.")
      )
      invalidField.reportValidity()
      invalidField.addEventListener("input", () => invalidField.setCustomValidity(""), { once: true })
      invalidField.focus()
      return
    }
  }

  selectCatalogItem(event) {
    const row = event.currentTarget.closest("[data-line-item]")
    const option = event.currentTarget.selectedOptions[0]
    if (!row) return

    row.dispatchEvent(new CustomEvent(option?.value ? "catalog:item-selected" : "catalog:item-cleared"))
    const name = row.querySelector('input[name$="[name]"]')
    const price = row.querySelector('input[name$="[manual_price]"]')
    const bundleSize = row.querySelector('input[name$="[bundle_quantity]"]')
    const barcodeField = row.querySelector("[data-item-entry-target='barcodeField']")
    if (price) price.readOnly = Boolean(option?.value)
    if (option?.value) {
      if (name) name.value = option.dataset.name || ""
      if (price) price.value = option.dataset.price || "0"
      if (bundleSize) bundleSize.value = option.dataset.bundleSize || "1"
      if (barcodeField) barcodeField.value = option.dataset.barcode || ""
    } else {
      if (name) name.value = ""
      if (price) price.value = ""
      if (bundleSize) bundleSize.value = "1"
      if (barcodeField) barcodeField.value = ""
    }
    this.refreshTotal()
  }

  refreshTotal() {
    if (!this.hasTotalTarget) return

    const activePanel = this.activePanel()
    if (!activePanel) return

    const subtotal = activePanel.dataset.orderType === "wash_and_fold"
      ? Number(activePanel.querySelector('input[name$="[manual_price]"]')?.value || 0)
      : Array.from(activePanel.querySelectorAll("[data-line-item]")).reduce((sum, item) => {
        const catalogItem = item.querySelector('select[name$="[item_id]"]')
        const selectedOption = catalogItem?.selectedOptions[0]
        const priceField = item.querySelector('input[name$="[manual_price]"]')
        const price = selectedOption?.value && priceField && priceField.value !== ""
          ? Number(priceField.value)
          : Number(priceField?.value || 0)
        const quantity = Number(item.querySelector('input[name$="[quantity]"]')?.value || 1)
        return sum + price * quantity
      }, 0)

    const total = Array.from(this.element.querySelectorAll("[data-surcharge-amount]:checked")).reduce((sum, surcharge) => {
      const amount = Number(surcharge.dataset.surchargeAmount || 0)
      if (surcharge.dataset.surchargeModifier === "procentage") return sum + subtotal * amount / 100
      return sum + (surcharge.dataset.surchargeModifier === "subtract" ? -amount : amount / 100)
    }, subtotal)

    this.totalTarget.textContent = new Intl.NumberFormat(undefined, { style: "currency", currency: "USD" }).format(total)
    this.renderSummary(activePanel)
  }

  renderSummary(panel) {
    if (!this.hasSummaryLinesTarget || !this.hasSummaryEmptyTarget) return

    this.summaryLinesTarget.replaceChildren()
    const rows = panel.dataset.orderType === "wash_and_fold"
      ? [{
        name: "Wash & Fold",
        quantity: Number(panel.querySelector('input[name$="[quantity]"]')?.value || 1),
        price: Number(panel.querySelector('input[name$="[manual_price]"]')?.value || 0)
      }]
      : Array.from(panel.querySelectorAll("[data-line-item]")).map((item) => {
        const selectedOption = item.querySelector('select[name$="[item_id]"]')?.selectedOptions[0]
        const name = selectedOption?.value
          ? selectedOption.dataset.name
          : item.querySelector('input[name$="[name]"]')?.value

        return {
          name: name || "New item",
          quantity: Number(item.querySelector('input[name$="[quantity]"]')?.value || 1),
          price: Number(item.querySelector('input[name$="[manual_price]"]')?.value || 0)
        }
      })

    this.summaryEmptyTarget.hidden = rows.length > 0
    rows.forEach((row) => {
      const line = document.createElement("div")
      line.className = "gl-pos-summary-item"

      const label = document.createElement("span")
      label.textContent = `${row.name} × ${row.quantity}`

      const price = document.createElement("strong")
      price.textContent = new Intl.NumberFormat(undefined, { style: "currency", currency: "USD" }).format(row.price * row.quantity)

      line.append(label, price)
      this.summaryLinesTarget.append(line)
    })
  }

  activePanel() {
    return this.hasLineItemsFrameTarget ? this.lineItemsFrameTarget : null
  }
}
