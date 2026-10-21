const sharp = require("sharp");
const path = require("path");

const output = path.resolve(__dirname, "../Evidence");
const assets = path.resolve(__dirname, "../CampusCompanion/Assets.xcassets/AppIcon.appiconset");

const esc = (value) => String(value)
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;");

function text(x, y, value, size = 16, weight = 400, fill = "#172033", anchor = "start") {
  return `<text x="${x}" y="${y}" font-family="-apple-system,BlinkMacSystemFont,Segoe UI,Arial,sans-serif" font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}">${esc(value)}</text>`;
}

function header(width, title, back = "") {
  return `
    <rect width="${width}" height="95" fill="#f7f9fc"/>
    ${text(23, 30, "9:41", 13, 700)}
    ${text(width - 23, 30, "●  ◔  ▰", 10, 700, "#172033", "end")}
    <rect x="0" y="47" width="${width}" height="48" fill="#ffffff"/>
    <line x1="0" y1="95" x2="${width}" y2="95" stroke="#dfe5ee"/>
    ${back ? text(15, 78, `‹  ${back}`, 16, 500, "#1c6fd1") : ""}
    ${text(width / 2, 78, title, 17, 700, "#172033", "middle")}`;
}

function phoneSvg(width, height, body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
    <rect width="${width}" height="${height}" fill="#f7f9fc"/>
    ${body}
  </svg>`;
}

function capIcon(cx, cy, size) {
  const s = size / 120;
  return `<g transform="translate(${cx - size / 2} ${cy - size / 2}) scale(${s})" fill="#1c6fd1">
    <circle cx="60" cy="60" r="58" opacity=".1"/>
    <path d="M16 50 60 27l44 23-44 23L16 50Zm17 14v20c16 12 38 12 54 0V64L60 78 33 64Zm60-4v25"/>
    <circle cx="93" cy="89" r="5"/>
  </g>`;
}

function welcomeSvg(width, height, compact = false) {
  const center = width / 2;
  const iconY = compact ? 140 : 166;
  const iconSize = compact ? 72 : 108;
  const titleY = compact ? 199 : 239;
  const subtitleY = titleY + 27;
  const startedY = subtitleY + 30;
  const cardY = compact ? 266 : 312;
  const cardX = 20;
  const cardW = width - 40;
  const cardH = compact ? 226 : 292;
  const buttonY = cardY + cardH + 14;
  const secondY = buttonY + 55;
  const fieldH = 38;
  const rows = compact ? 34 : 44;

  const body = `${header(width, "Campus Companion")}
    ${capIcon(center, iconY, iconSize)}
    ${text(center, titleY, "Campus Companion", compact ? 25 : 28, 750, "#172033", "middle")}
    ${text(center, subtitleY, "Your Campus, In Your Pocket", 15, 400, "#687386", "middle")}
    ${text(center, startedY, "Get Started", 15, 650, "#1c6fd1", "middle")}
    <rect x="${cardX}" y="${cardY}" width="${cardW}" height="${cardH}" rx="18" fill="#ffffff" stroke="#dfe5ee"/>
    ${text(cardX + 15, cardY + 23, "Student name", 11, 650, "#687386")}
    <rect x="${cardX + 14}" y="${cardY + 31}" width="${cardW - 28}" height="${fieldH}" rx="9" fill="#fbfcfe" stroke="#dfe5ee"/>
    ${text(cardX + 26, cardY + 56, "Enter your name", 14, 400, "#9aa4b3")}
    ${text(cardX + 15, cardY + 31 + fieldH + rows - 10, "Notify me about events", 14)}
    <rect x="${cardX + cardW - 63}" y="${cardY + 31 + fieldH + rows - 31}" width="48" height="28" rx="14" fill="#cfd5df"/>
    <circle cx="${cardX + cardW - 49}" cy="${cardY + 31 + fieldH + rows - 17}" r="12" fill="#ffffff"/>
    <rect x="${cardX + 14}" y="${cardY + 31 + fieldH + rows}" width="${cardW - 28}" height="32" rx="8" fill="#e9edf3"/>
    <rect x="${cardX + 17}" y="${cardY + 31 + fieldH + rows + 3}" width="${(cardW - 34) / 2}" height="26" rx="6" fill="#ffffff"/>
    ${text(cardX + cardW * .27, cardY + 31 + fieldH + rows + 22, "Student", 12, 650, "#172033", "middle")}
    ${text(cardX + cardW * .73, cardY + 31 + fieldH + rows + 22, "Faculty", 12, 400, "#172033", "middle")}
    ${text(cardX + 15, cardY + 31 + fieldH + rows + 61, "Preferred event date", 13)}
    <rect x="${cardX + cardW - 140}" y="${cardY + 31 + fieldH + rows + 43}" width="125" height="30" rx="7" fill="#f2f5f9"/>
    ${text(cardX + cardW - 77, cardY + 31 + fieldH + rows + 63, "Oct 12, 2026", 11, 600, "#172033", "middle")}
    ${text(cardX + 15, cardY + 31 + fieldH + rows + 99, "Number of guests", 13)}
    <rect x="${cardX + cardW - 105}" y="${cardY + 31 + fieldH + rows + 81}" width="90" height="30" rx="7" fill="#f5f7fa" stroke="#dfe5ee"/>
    ${text(cardX + cardW - 90, cardY + 31 + fieldH + rows + 102, "−", 17, 500, "#1c6fd1", "middle")}
    ${text(cardX + cardW - 60, cardY + 31 + fieldH + rows + 101, "1", 13, 700, "#172033", "middle")}
    ${text(cardX + cardW - 30, cardY + 31 + fieldH + rows + 102, "+", 17, 500, "#1c6fd1", "middle")}
    <rect x="${cardX}" y="${buttonY}" width="${cardW}" height="46" rx="12" fill="#1c6fd1"/>
    ${text(center, buttonY + 29, "Explore Campus", 16, 700, "#ffffff", "middle")}
    <rect x="${cardX}" y="${secondY}" width="${cardW}" height="46" rx="12" fill="#ffffff" stroke="#1c6fd1"/>
    ${text(center, secondY + 29, "Campus Announcements", 16, 700, "#1c6fd1", "middle")}
    ${height > secondY + 75 ? text(center, secondY + 70, "Exercises 1–3 complete", 10, 400, "#687386", "middle") : ""}`;
  return phoneSvg(width, height, body);
}

function detailSvg(width, height) {
  const x = 22, w = width - 44, y = 205, h = 440;
  const rows = [
    ["Role", "Faculty"],
    ["Notifications", "On"],
    ["Preferred date", "October 18, 2026"],
    ["Guests", "3"]
  ];
  let rowSvg = "";
  rows.forEach(([label, value], index) => {
    const rowY = y + 160 + index * 54;
    rowSvg += `<line x1="${x + 20}" y1="${rowY - 22}" x2="${x + w - 20}" y2="${rowY - 22}" stroke="#dfe5ee"/>`;
    rowSvg += text(x + 20, rowY + 2, label, 14, 400, "#687386");
    rowSvg += text(x + w - 20, rowY + 2, value, 14, 650, "#172033", "end");
  });
  return phoneSvg(width, height, `${header(width, "Campus Events", "Campus")}
    <rect x="${x}" y="${y}" width="${w}" height="${h}" rx="22" fill="#ffffff" stroke="#dfe5ee"/>
    <rect x="${x + 20}" y="${y + 24}" width="69" height="26" rx="13" fill="#eaf3ff"/>
    ${text(x + 54.5, y + 42, "FACULTY", 10, 750, "#1c6fd1", "middle")}
    ${text(x + 20, y + 92, "Welcome, Julian!", 25, 750)}
    ${text(x + 20, y + 125, "Your campus preferences are ready.", 14, 400, "#687386")}
    ${rowSvg}`);
}

const announcements = [
  ["Enrollment Period Extended", "Academics · August 3, 2026", "Urgent · Registrar", true],
  ["Campus Wi-Fi Maintenance", "Technology · August 7, 2026", "Urgent · IT Services", true],
  ["Student Organization Fair", "Student Life · August 12, 2026", "Normal · Student Affairs", false],
  ["Library Extended Hours", "Facilities · August 15, 2026", "Normal · University Library", false],
  ["Scholarship Applications Open", "Financial Aid · August 20, 2026", "Normal · Scholarships Office", false],
  ["Emergency Preparedness Drill", "Safety · August 25, 2026", "Urgent · Campus Security", true]
];

function announcementsSvg(width, height) {
  let rows = "";
  announcements.forEach(([title, date, meta, urgent], index) => {
    const y = 101 + index * 92;
    rows += `<rect x="0" y="${y}" width="${width}" height="92" fill="${urgent ? "#fff2f2" : "#ffffff"}"/>`;
    rows += `<line x1="0" y1="${y + 92}" x2="${width}" y2="${y + 92}" stroke="#dfe5ee"/>`;
    rows += `<rect x="15" y="${y + 26}" width="40" height="40" rx="12" fill="${urgent ? "#ffe0e0" : "#eaf3ff"}"/>`;
    rows += text(35, y + 53, urgent ? "!" : "◆", 18, 750, urgent ? "#d93636" : "#1c6fd1", "middle");
    rows += text(67, y + 29, title, 14, 700);
    rows += text(67, y + 51, date, 11, 400, "#687386");
    rows += text(67, y + 70, meta, 11, urgent ? 700 : 400, urgent ? "#d93636" : "#687386");
    rows += text(width - 18, y + 54, "›", 23, 400, "#9aa4b3", "end");
  });
  return phoneSvg(width, height, `${header(width, "Announcements", "Campus")}${rows}`);
}

function announcementDetailSvg(width, height) {
  const x = 22, w = width - 44, y = 205, h = 440;
  const rows = [
    ["Date", "August 3, 2026"],
    ["Category", "Academics"],
    ["Priority", "Urgent"],
    ["Posted by", "Registrar"]
  ];
  let rowSvg = "";
  rows.forEach(([label, value], index) => {
    const rowY = y + 160 + index * 54;
    rowSvg += `<line x1="${x + 20}" y1="${rowY - 22}" x2="${x + w - 20}" y2="${rowY - 22}" stroke="#dfe5ee"/>`;
    rowSvg += text(x + 20, rowY + 2, label, 14, 400, "#687386");
    rowSvg += text(x + w - 20, rowY + 2, value, 14, 650, label === "Priority" ? "#d93636" : "#172033", "end");
  });
  return phoneSvg(width, height, `${header(width, "Academics", "Back")}
    <rect x="${x}" y="${y}" width="${w}" height="${h}" rx="22" fill="#ffffff" stroke="#dfe5ee"/>
    <rect x="${x + 20}" y="${y + 24}" width="66" height="26" rx="13" fill="#ffe0e0"/>
    ${text(x + 53, y + 42, "URGENT", 10, 750, "#d93636", "middle")}
    ${text(x + 20, y + 89, "Enrollment Period", 24, 750)}
    ${text(x + 20, y + 117, "Extended", 24, 750)}
    ${rowSvg}`);
}

function appIconSvg() {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
    <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#2494ed"/><stop offset="1" stop-color="#1148a1"/></linearGradient></defs>
    <rect width="1024" height="1024" rx="220" fill="url(#g)"/>
    <circle cx="512" cy="512" r="330" fill="#ffffff" opacity=".13"/>
    <path d="M190 418 512 250l322 168-322 168L190 418Zm124 105v169c117 88 279 88 396 0V523L512 625 314 523Zm438-30v184" fill="#ffffff"/>
    <circle cx="752" cy="713" r="34" fill="#ffffff"/>
  </svg>`;
}

async function writePng(svg, file) {
  await sharp(Buffer.from(svg)).png().toFile(file);
}

(async () => {
  await Promise.all([
    writePng(welcomeSvg(393, 852, false), path.join(output, "exercise-1-welcome-iphone-15-pro.png")),
    writePng(welcomeSvg(375, 667, true), path.join(output, "exercise-1-welcome-iphone-se.png")),
    writePng(detailSvg(393, 852), path.join(output, "exercise-2-personalized-detail.png")),
    writePng(announcementsSvg(393, 852), path.join(output, "exercise-3-announcements-list.png")),
    writePng(announcementDetailSvg(393, 852), path.join(output, "exercise-3-announcement-detail.png")),
    writePng(appIconSvg(), path.join(assets, "AppIcon-1024.png"))
  ]);
  console.log("Evidence screenshots and app icon generated.");
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
