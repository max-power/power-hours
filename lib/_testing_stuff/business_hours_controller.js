// app/javascript/controllers/business_hours_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["rowTemplate", "startSlider", "display", "hiddenInput"];

  connect() {
    ["mon", "tue", "wed", "thu", "fri", "sat", "sun"].forEach((day) => {
      this.addDayRow(day);
    });
  }

  addDayRow(day) {
    const clone = this.rowTemplateTarget.content.cloneNode(true);
    clone.querySelector("[data-day-label]").textContent = day;
    // Set the hidden input name dynamically: business[opening_hours][mon][]
    clone.querySelector('input[type="hidden"]').name =
      `business[opening_hours][${day}][]`;

    this.element.querySelector("#hours-container").appendChild(clone);
  }

  update(event) {
    const row = event.target.closest(".flex");
    const startVal = row.querySelector(
      '[data-business-hours-target="startSlider"]',
    ).value;

    // Simple mock: we assume a fixed 8-hour window for this example
    // In a real app, you'd have a double-ended range slider (like noUiSlider)
    const startTime = this.minutesToTime(startVal);
    const endTime = this.minutesToTime(parseInt(startVal) + 480);

    const display = row.querySelector('[data-business-hours-target="display"]');
    const hidden = row.querySelector(
      '[data-business-hours-target="hiddenInput"]',
    );

    display.textContent = `${startTime} - ${endTime}`;
    hidden.value = `${startTime}..${endTime}`; // This is the DSL-ready string!
  }

  minutesToTime(totalMinutes) {
    const hours = Math.floor(totalMinutes / 60) % 24;
    const minutes = totalMinutes % 60;
    return `${hours.toString().padStart(2, "0")}:${minutes.toString().padStart(2, "0")}`;
  }
}

// // app/javascript/controllers/business_hours_controller.js
// // ... previous connect() and addDayRow() methods ...

// update(event) {
//   const row = event.target.closest('.day-row')
//   const startMins = parseInt(row.querySelector('[data-business-hours-target="startSlider"]').value)

//   // Logic: Start time + 4 hours (240 mins)
//   const endMins = (startMins + 240) % 1440

//   const startStr = this.minutesToTime(startMins)
//   const endStr = this.minutesToTime(endMins)

//   const display = row.querySelector('[data-business-hours-target="display"]')
//   const hidden = row.querySelector('[data-business-hours-target="hiddenInput"]')

//   display.textContent = `${startStr} - ${endStr}`

//   // This sends "08:00..12:00" to your Rails OpeningHours::Type
//   hidden.value = `${startStr}..${endStr}`
// }
