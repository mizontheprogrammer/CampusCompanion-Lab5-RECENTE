const announcements = [
  { title: "Enrollment Period Extended", date: "August 3, 2026", category: "Academics", priority: "Urgent", postedBy: "Registrar" },
  { title: "Campus Wi-Fi Maintenance", date: "August 7, 2026", category: "Technology", priority: "Urgent", postedBy: "IT Services" },
  { title: "Student Organization Fair", date: "August 12, 2026", category: "Student Life", priority: "Normal", postedBy: "Student Affairs" },
  { title: "Library Extended Hours", date: "August 15, 2026", category: "Facilities", priority: "Normal", postedBy: "University Library" },
  { title: "Scholarship Applications Open", date: "August 20, 2026", category: "Financial Aid", priority: "Normal", postedBy: "Scholarships Office" },
  { title: "Emergency Preparedness Drill", date: "August 25, 2026", category: "Safety", priority: "Urgent", postedBy: "Campus Security" }
];

const screens = [...document.querySelectorAll(".screen")];
const history = ["welcome-screen"];
let guests = 1;

function showScreen(id, push = true) {
  screens.forEach((screen) => screen.classList.toggle("active", screen.id === id));
  if (push && history.at(-1) !== id) history.push(id);
}

function formatDate(dateValue) {
  if (!dateValue) return "Not selected";
  return new Intl.DateTimeFormat("en-US", {
    dateStyle: "long",
    timeZone: "UTC"
  }).format(new Date(`${dateValue}T00:00:00Z`));
}

function detailMarkup({ badge, urgent = false, title, rows }) {
  return `
    <article class="detail-card">
      <span class="detail-badge ${urgent ? "urgent" : ""}">${badge}</span>
      <h2>${title}</h2>
      <dl class="detail-list">
        ${rows.map(([term, value]) => `<div><dt>${term}</dt><dd>${value}</dd></div>`).join("")}
      </dl>
    </article>`;
}

document.querySelector("#get-started").addEventListener("click", () => {
  document.querySelector("#subtitle").textContent = "Let's get started!";
});

document.querySelector("#guest-minus").addEventListener("click", () => {
  guests = Math.max(1, guests - 1);
  document.querySelector("#guest-count").value = guests;
});

document.querySelector("#guest-plus").addEventListener("click", () => {
  guests = Math.min(10, guests + 1);
  document.querySelector("#guest-count").value = guests;
});

document.querySelector("#explore-campus").addEventListener("click", () => {
  const enteredName = document.querySelector("#student-name").value.trim();
  const name = enteredName || "Student";
  const role = document.querySelector('input[name="role"]:checked').value;
  const notifications = document.querySelector("#notify-switch").checked ? "On" : "Off";
  const eventDate = formatDate(document.querySelector("#event-date").value);

  document.querySelector("#detail-title").textContent = "Campus Events";
  document.querySelector("#detail-content").innerHTML = detailMarkup({
    badge: role,
    title: `Welcome, ${name}!`,
    rows: [
      ["Role", role],
      ["Notifications", notifications],
      ["Preferred date", eventDate],
      ["Guests", guests]
    ]
  });
  showScreen("detail-screen");
});

function renderAnnouncements() {
  const list = document.querySelector("#announcements-list");
  list.innerHTML = "";
  announcements.forEach((announcement, index) => {
    const urgent = announcement.priority === "Urgent";
    const row = document.createElement("button");
    row.type = "button";
    row.className = `announcement-row ${urgent ? "urgent" : ""}`;
    row.dataset.index = index;
    row.innerHTML = `
      <span class="announcement-icon" aria-hidden="true">${urgent ? "!" : "◆"}</span>
      <span class="announcement-copy">
        <strong>${announcement.title}</strong>
        <small>${announcement.category} · ${announcement.date}</small>
        <small class="${urgent ? "urgent-copy" : ""}">${announcement.priority} · ${announcement.postedBy}</small>
      </span>
      <span class="disclosure" aria-hidden="true">›</span>`;
    row.addEventListener("click", () => showAnnouncementDetail(announcement));
    list.append(row);
  });
}

function showAnnouncementDetail(announcement) {
  const urgent = announcement.priority === "Urgent";
  document.querySelector("#detail-title").textContent = announcement.category;
  document.querySelector("#detail-content").innerHTML = detailMarkup({
    badge: announcement.priority,
    urgent,
    title: announcement.title,
    rows: [
      ["Date", announcement.date],
      ["Category", announcement.category],
      ["Priority", announcement.priority],
      ["Posted by", announcement.postedBy]
    ]
  });
  showScreen("detail-screen");
}

document.querySelector("#show-announcements").addEventListener("click", () => {
  renderAnnouncements();
  showScreen("announcements-screen");
});

document.querySelectorAll("[data-back]").forEach((button) => {
  button.addEventListener("click", () => {
    if (history.length > 1) history.pop();
    showScreen(history.at(-1), false);
  });
});

renderAnnouncements();
