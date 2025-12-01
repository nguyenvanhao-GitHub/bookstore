document.addEventListener("DOMContentLoaded", () => {
  const body = document.body;
  const toggle = document.getElementById("darkModeToggle");

  // Áp dụng dark mode nếu đã lưu
  if (localStorage.getItem("darkMode") === "true") {
    body.classList.add("dark-mode");
    toggle.checked = true;
    applyDarkToElements(true);
  }

  toggle.addEventListener("change", () => {
    const isDark = toggle.checked;
    body.classList.toggle("dark-mode", isDark);
    applyDarkToElements(isDark);
    localStorage.setItem("darkMode", isDark);
  });

  function applyDarkToElements(isDark) {
    document.querySelectorAll(".navbar, .container, .card, footer, .form-control").forEach(el => {
      el.classList.toggle("dark-mode", isDark);
    });
  }
});
