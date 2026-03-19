(function () {
  const DAYS = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

  class OpeningHoursController extends Stimulus.Controller {
    static targets = ["container", "debugOutput", "includeEmpty"];

    connect() {
      this.nextId = 1;
      this.state = Object.fromEntries(DAYS.map((day) => [day, []]));
      this.weekdayFormatter = new Intl.DateTimeFormat(undefined, { weekday: "long" });

      this.insertWindow("mon", "09:00", "12:00");
      this.insertWindow("mon", "13:00", "17:00");
      this.insertWindow("fri", "22:00", "02:00");

      this.render();
    }

    addWindow(event) {
      this.insertWindow(event.currentTarget.dataset.day);
      this.render();
    }

    removeWindow(event) {
      const row = event.currentTarget.closest(".window-row");
      if (!row) return;

      const day = row.dataset.day;
      const id = Number(row.dataset.id);
      this.state[day] = this.state[day].filter((window) => window.id !== id);
      this.render();
    }

    updateWindow(event) {
      const input = event.currentTarget;
      const row = input.closest(".window-row");
      if (!row) return;

      const day = row.dataset.day;
      const id = Number(row.dataset.id);
      const window = this.state[day].find((item) => item.id === id);
      if (!window) return;

      window[input.dataset.field] = input.value;
      this.renderPayload();
    }

    refreshPayload() {
      this.renderPayload();
    }

    insertWindow(day, start = "09:00", end = "17:00") {
      this.state[day].push({ id: this.nextId++, start, end });
    }

    isComplete(window) {
      return Boolean(window.start && window.end);
    }

    toRangeString(window) {
      return `${window.start}-${window.end}`;
    }

    buildOpeningHours(includeEmpty) {
      const openingHours = {};

      DAYS.forEach((day) => {
        const ranges = this.state[day]
          .filter((window) => this.isComplete(window))
          .map((window) => this.toRangeString(window));

        if (includeEmpty || ranges.length > 0) {
          openingHours[day] = ranges;
        }
      });

      return openingHours;
    }

    formatDayLabel(day) {
      try {
        const index = DAYS.indexOf(day);
        if (index < 0) return day;

        // Jan 1, 2024 is a Monday; use local noon to avoid TZ rollover.
        const date = new Date(2024, 0, 1 + index, 12, 0, 0, 0);
        return this.weekdayFormatter.format(date);
      } catch (_error) {
        return day;
      }
    }

    dayMarkup(day) {
      const windows = this.state[day];

      const windowsMarkup = windows
        .map((window) => {
          return `
            <div class="window-row" data-day="${day}" data-id="${window.id}">
              <div class="time-range">
                <input
                  type="time"
                  step="900"
                  value="${window.start}"
                  data-field="start"
                  data-action="input->opening-hours#updateWindow"
                />
                <span class="window-sep">&ndash;</span>
                <input
                  type="time"
                  step="900"
                  value="${window.end}"
                  data-field="end"
                  data-action="input->opening-hours#updateWindow"
                />
              </div>
              <button
                type="button"
                class="btn btn-remove"
                data-action="click->opening-hours#removeWindow"
                aria-label="Remove window"
                title="Remove window"
              >
                ×
              </button>
            </div>
          `;
        })
        .join("");

      const addButtonMarkup = `
        <button
          type="button"
          class="btn btn-add"
          data-day="${day}"
          data-action="click->opening-hours#addWindow"
        >
          + add window
        </button>
      `;

      const bodyMarkup =
        windows.length === 0
          ? `<div class="day-actions">${addButtonMarkup}</div>`
          : `${windowsMarkup}<div class="day-actions">${addButtonMarkup}</div>`;

      return `
        <section class="day-card" data-day-card="${day}">
          <div class="day-grid">
            <span class="day-label">${this.formatDayLabel(day)}</span>
            <div class="day-content">${bodyMarkup}</div>
          </div>
        </section>
      `;
    }

    renderPayload() {
      const includeEmpty = this.includeEmptyTarget.checked;
      const payload = {
        business: {
          opening_hours: this.buildOpeningHours(includeEmpty),
        },
      };

      this.debugOutputTarget.textContent = JSON.stringify(payload, null, 2);
    }

    render() {
      this.containerTarget.innerHTML = DAYS.map((day) => this.dayMarkup(day)).join("");
      this.renderPayload();
    }
  }

  window.OpeningHoursController = OpeningHoursController;
})();
